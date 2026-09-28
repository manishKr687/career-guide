-- Repairs exam_colleges, which had fallen 72 rows behind college_exams.
--
-- college_exams (College.exams) and exam_colleges (Exam.relatedColleges) are
-- the two directions of one relationship, per this project's "store every
-- relationship in both directions" convention. CollegeService keeps them in
-- step on the admin write path -- but every college seeded by a MIGRATION
-- (V56-V65: the NITs, IITs and the 30 NIRF medical colleges) inserted into
-- college_exams only, because SQL bypasses the service layer entirely. The
-- invariant lived in Java; half the writes never went through Java.
--
-- The visible symptom: GET /api/exams/neet-ug returned 2 colleges while 25
-- colleges actually listed neet-ug, so 23 medical colleges were missing from
-- the NEET-UG page. Same for jee-advanced (the IITs) and jee-main (the NITs).
--
-- exam_colleges.sort_order backs an @OrderColumn list, so it must stay dense
-- (0..n-1 per exam_slug) or Hibernate materializes nulls into the List -- the
-- V58 failure. New rows therefore continue each exam's existing numbering
-- rather than restarting at 0, ordered by college_slug so the result is
-- deterministic and this migration is reproducible from scratch.
--
-- Direction is one-way by design: the check below confirmed 0 rows exist in
-- exam_colleges that are absent from college_exams, so college_exams is the
-- authoritative side and nothing needs copying back.

INSERT INTO exam_colleges (exam_slug, college_slug, sort_order)
SELECT
    d.exam_slug,
    d.college_slug,
    COALESCE(e.max_sort, -1) + ROW_NUMBER() OVER (
        PARTITION BY d.exam_slug ORDER BY d.college_slug
    )
FROM (
    SELECT exam_slug, college_slug FROM college_exams
    EXCEPT
    SELECT exam_slug, college_slug FROM exam_colleges
) d
LEFT JOIN (
    SELECT exam_slug, MAX(sort_order) AS max_sort
    FROM exam_colleges
    GROUP BY exam_slug
) e ON e.exam_slug = d.exam_slug;

-- Self-verifying: fail the migration loudly rather than leave the table in a
-- state that only shows up later as a NullPointerException or a short list.
DO $$
DECLARE bad int;
BEGIN
    SELECT count(*) INTO bad FROM (
        SELECT exam_slug FROM exam_colleges
        GROUP BY exam_slug
        HAVING min(sort_order) <> 0 OR max(sort_order) <> count(*) - 1
    ) x;
    IF bad > 0 THEN
        RAISE EXCEPTION 'exam_colleges.sort_order is not dense for % exam(s)', bad;
    END IF;

    SELECT count(*) INTO bad FROM (
        SELECT exam_slug, college_slug FROM college_exams
        EXCEPT
        SELECT exam_slug, college_slug FROM exam_colleges
    ) y;
    IF bad > 0 THEN
        RAISE EXCEPTION 'exam_colleges still missing % row(s) from college_exams', bad;
    END IF;
END $$;
