-- Repairs a sort_order integrity violation found while verifying the
-- College page's data flow end-to-end (NIT Patna): College.degrees is a
-- Hibernate @OrderColumn list, which requires a dense, gap-free, unique
-- sort_order per college_slug -- any duplicate or gap corrupts the
-- materialized list (a duplicate value collapses two rows onto one list
-- slot, leaving another slot null), which is exactly what was hitting a
-- NullPointerException on every GET /api/colleges/nit-patna: nit-patna had
-- two rows both at sort_order 3 (degree_slug 'b-tech-m-tech' from V57, and
-- an unaccounted-for 'phd' row) and none at 2. b-tech/b-arch/b-tech-m-tech
-- came from this codebase's own migrations (V53/V56/V57); the extra 'phd'
-- row's origin isn't attributable to any of them -- kept rather than
-- dropped, since NIT Patna offering a PhD is itself a true, well-known
-- fact (matching this migration series' own earlier "PhD across
-- departments" audit finding), it just needs a sort_order that doesn't
-- collide with anything else.
--
-- Renumbers every college's group, not just nit-patna's, since the same
-- class of drift could in principle affect any of them; this is a no-op
-- for every college whose rows are already a clean 0..n-1 sequence.

UPDATE college_degrees cd
SET sort_order = renumbered.new_order
FROM (
    SELECT college_slug, degree_slug,
           ROW_NUMBER() OVER (PARTITION BY college_slug ORDER BY sort_order, degree_slug) - 1 AS new_order
    FROM college_degrees
) renumbered
WHERE cd.college_slug = renumbered.college_slug
  AND cd.degree_slug = renumbered.degree_slug
  AND cd.sort_order <> renumbered.new_order;
