-- Moves all 4 "IT & Software" careers (Data Scientist, Software Engineer,
-- Cybersecurity Analyst, Cloud Architect) into "Engineering & Technology",
-- per request. The `it-software` category row itself is deliberately left
-- in place rather than deleted -- it just has zero careers after this -- see
-- backend README for why.
--
-- sort_order is "index of this career within its category" (read by
-- CareerService.nextSortOrder and AssessmentService.getRecommendedCareers's
-- per-category ordering), not an @OrderColumn-mapped list index, so there's
-- no Hibernate gap-crash risk here (unlike V14) -- but the new values still
-- continue engineering-technology's existing 0..11 sequence (12 careers)
-- rather than colliding with it, preserving the same relative order these 4
-- had within IT & Software.

UPDATE careers SET category_slug = 'engineering-technology', sort_order = 12 WHERE slug = 'data-scientist';
UPDATE careers SET category_slug = 'engineering-technology', sort_order = 13 WHERE slug = 'software-engineer';
UPDATE careers SET category_slug = 'engineering-technology', sort_order = 14 WHERE slug = 'cybersecurity-analyst';
UPDATE careers SET category_slug = 'engineering-technology', sort_order = 15 WHERE slug = 'cloud-architect';

-- The assessment quiz scores answers against category slugs and pools
-- recommended careers straight from a scored category's career list
-- (AssessmentService.getRecommendedCareers). With it-software now empty,
-- leaving these weights pointed at it would let "IT & Software" surface as
-- a user's top-scoring category while having zero careers to actually
-- recommend -- a visible dead end. Redirecting the weight to
-- engineering-technology (already the target of the other tech-leaning
-- answers, and already in the same "cluster-tech" branch, see
-- AssessmentFlow.tsx) folds that signal in rather than losing it.
--
-- None of the 7 rows below collide with an existing engineering-technology
-- row for the same option_id (checked first: the two sets of option_ids
-- don't overlap), so this is a plain rename, not a merge-and-sum.

UPDATE assessment_option_weights SET category_slug = 'engineering-technology' WHERE category_slug = 'it-software';
