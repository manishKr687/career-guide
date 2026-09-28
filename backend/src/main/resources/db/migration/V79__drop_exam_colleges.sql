-- Step 2 of 2: drop exam_colleges, now that V78's state has been verified
-- running -- Exam.relatedColleges reads college_exams as the inverse side and
-- returns identical data (neet-ug 25, jee-advanced 23, jee-main 31, cat 2,
-- each matching college_exams exactly).
--
-- Split across two migrations on purpose. The general rule is to stop using a
-- table in one step and remove it in another, so there is a verified
-- intermediate state to fall back on; V76 broke that rule deliberately
-- because stage_careers held 0 rows, but this table held 92 and the rule
-- earns its keep here.
--
-- Nothing recoverable is lost: every row in exam_colleges also exists in
-- college_exams (V75 reconciled them, and afterMigrate.sql has asserted it on
-- every boot since). The authoritative side keeps all 92 pairs.

DROP TABLE exam_colleges;
