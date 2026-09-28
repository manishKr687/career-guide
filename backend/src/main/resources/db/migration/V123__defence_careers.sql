-- Fills the Defence category, which had zero careers.
--
-- cds-exam and nda-exam were already in the catalog, categorised Defence, with
-- ZERO careers linked to either -- the same dead end ibps-po had before V121. A
-- student who found the NDA exam page had nowhere to go from it.
--
-- TWO CAREERS, AND THEY ARE DIFFERENT IN KIND
--
--   defence-services  The commissioned service route: NDA after class 12, or CDS
--                     after a degree. This is a service rather than a field of
--                     study, which stretches the usual meaning of a Career row
--                     here -- but the alternative is leaving the two exams
--                     pointing at nothing, and "how do I join the forces" is a
--                     question this catalog should answer. Its specializations
--                     are the three services and its roles are the ranks, so the
--                     Career -> Specialization -> Role shape still holds.
--   defence-studies   Defence and Strategic Studies, a genuine academic
--                     discipline taught to MA and PhD, leading to teaching,
--                     research and policy analysis rather than to a commission.
--
-- The subject and its degree pairs are added here, following the pattern
-- economics and political-science use: a generic degree family plus the subject
-- it is taken in, composed into "M.A. (Defence and Strategic Studies)" at render
-- time rather than stored as its own degree row.
--
-- SOURCES. Retrieved 2026-09-28.
--
--   defence-services -- the 7th CPC Defence pay matrix:
--       Lieutenant (entry)  Level 10, basic 56,100 / month
--       apex (General)      fixed 2,50,000 / month
--     plus Military Service Pay of 15,500 / month for officers, which is a
--     separate element paid only to defence personnel.
--     https://testbook.com/defence/indian-army-lieutenant-salary
--     https://www.cavalier.in/indian-army-salary-and-pay-scale-structure
--
--   defence-studies -- the UGC academic pay matrix, as used for
--   political-science in V122:
--       Assistant Professor  Academic Level 10, basic 57,700 / month
--       Professor            Academic Level 14, to 2,18,200 / month
--     https://7thpaycommissionnews.in/ugc-pay-revision-as-per-7th-pay-commission/
--     https://testbook.com/government-teacher-jobs/professor-salary
--
-- HOW THE LPA RANGES WERE DERIVED. Basic pay only, monthly x 12, the same method
-- as V118, V120, V121 and V122 so all five batches stay comparable.
--
--       defence-services  56,100 x 12 = 6.73L  ->  2,50,000 x 12 = 30.00L
--       defence-studies   57,700 x 12 = 6.92L  ->  2,18,200 x 12 = 26.18L
--
-- MILITARY SERVICE PAY IS DELIBERATELY NOT IN THE RANGE, and this is a judgment
-- worth recording. MSP is 15,500 a month -- 1.86L a year -- and unlike DA or HRA
-- it does not vary by posting city, so folding it in would be defensible and
-- would raise the floor to about 8.6L. It is excluded anyway, because every other
-- career in this catalog quotes basic pay alone and a reader comparing two rows
-- must be comparing the same thing. It is named in the career's highlights
-- instead, where a reader sees it rather than silently benefiting or losing from
-- an inconsistent method.

INSERT INTO subjects (slug, title, description, icon, category_slug) VALUES
    ('defence-and-strategic-studies',
     'Defence and Strategic Studies',
     'The study of war, security and statecraft: military history, strategic thought, defence policy and international security.',
     'shield',
     'defence');

INSERT INTO degree_subjects (degree_slug, subject_slug) VALUES
    ('ba',  'defence-and-strategic-studies'),
    ('ma',  'defence-and-strategic-studies'),
    ('phd', 'defence-and-strategic-studies');

INSERT INTO careers (
    slug, title, category_slug, tagline, demand, typical_work, salary_range,
    salary_min_lpa, salary_max_lpa, growth_path, icon, description,
    highlights, work_environments, sort_order
) VALUES
(
    'defence-services',
    'Defence Services',
    'defence',
    'Defence Services -- specializations, skills & career paths',
    'Competitive',
    'Officers in the Defence Services lead and train troops, command units and equipment in the field, take operational decisions under pressure and time constraints, and move through the commissioned ranks into staff and command appointments.',
    '₹6.73L – ₹30L / year',
    6.73, 30.00,
    ARRAY['Lieutenant', 'Captain', 'Major', 'Colonel', 'Brigadier', 'General Officer'],
    'shield',
    'The Defence Services commission officers into the Army, Navy and Air Force. Entry is by examination and selection rather than by application: NDA after class 12, through which cadets also earn a degree, or CDS after graduating. Selection includes the five-day SSB interview, which tests judgement and temperament as much as knowledge, and the medical standard is absolute. What follows is unlike most careers in this catalog -- pay, rank and progression are all published in advance, the training is continuous, and postings are decided by the service rather than chosen. It is also the only route here where physical fitness is a standing condition of employment rather than a personal matter.',
    ARRAY[
        'Two entry routes: NDA after class 12 (a degree comes with it) or CDS after graduation',
        'Selection turns on the five-day SSB interview, not the written exam alone',
        'Officers receive Military Service Pay of ₹15,500 a month on top of the basic pay shown',
        'Rank, pay and progression are all published in advance',
        'Medical and physical standards are a continuing condition, not a one-off test'
    ],
    -- 'Training Academies' rather than a new 'Ships' value: it is already in the
    -- catalog's vocabulary and is accurate, since officers cycle back through
    -- NDA/IMA/OTA throughout a career. Field Work already covers deployment.
    ARRAY['Field Work', 'Government Bodies', 'Training Academies', 'Collaborative Teams'],
    0
),
(
    'defence-studies',
    'Defence Studies',
    'defence',
    'Defence Studies -- specializations, skills & career paths',
    'Emerging',
    'Professionals in Defence Studies research and teach strategy and security, analyse conflicts and defence policy for institutes and government, and write the assessments that procurement and doctrine decisions are argued from.',
    '₹6.92L – ₹26.18L / year',
    6.92, 26.18,
    ARRAY['Research Assistant', 'Research Associate', 'Assistant Professor', 'Associate Professor', 'Professor'],
    'book',
    'Defence and Strategic Studies is the academic study of war and security -- why conflicts start, how states deter each other, what a doctrine or a procurement decision actually assumes. It is taught at MA and PhD level in Indian universities and leads to teaching, think-tank research and policy analysis, not to a commission: a serving officer and a strategic studies scholar do related work from opposite sides. UGC-NET is the gate into university teaching, and the field draws graduates from history, political science and international relations as much as from its own degree.',
    ARRAY[
        'An academic discipline, not a route to a commission',
        'Taught to MA and PhD; UGC-NET is the gate into university teaching',
        'Feeds think-tank and policy-analysis work alongside academia',
        'Open to graduates from history, political science and international relations'
    ],
    ARRAY['Universities', 'Government Bodies', 'Research Labs', 'Collaborative Teams'],
    1
);

INSERT INTO career_degrees (career_slug, degree_slug, subject_slug, sort_order) VALUES
    ('defence-services', 'b-tech', NULL, 0),
    ('defence-services', 'b-sc',   NULL, 1),
    ('defence-services', 'ba',     NULL, 2),
    ('defence-studies',  'ba',  'defence-and-strategic-studies', 0),
    ('defence-studies',  'ma',  'defence-and-strategic-studies', 1),
    ('defence-studies',  'phd', 'defence-and-strategic-studies', 2);

INSERT INTO career_exams (career_slug, exam_slug, sort_order) VALUES
    ('defence-services', 'nda-exam', 0),
    ('defence-services', 'cds-exam', 1),
    ('defence-studies',  'cuet',     0),
    ('defence-studies',  'ugc-net',  1);

-- The mirror: career_exams and exam_careers are compared on every boot, so both
-- sides are written and sort_order continues each exam's existing sequence.
INSERT INTO exam_careers (exam_slug, career_slug, sort_order)
SELECT ce.exam_slug, ce.career_slug,
       COALESCE((SELECT max(sort_order) + 1 FROM exam_careers x WHERE x.exam_slug = ce.exam_slug), 0)
         + row_number() OVER (PARTITION BY ce.exam_slug ORDER BY ce.career_slug) - 1
FROM career_exams ce
WHERE ce.career_slug IN ('defence-services', 'defence-studies');

-- sort_order is NOT NULL with no default and density 0..n-1 per career is
-- asserted on boot.
INSERT INTO career_skills (career_slug, skill_slug, sort_order) VALUES
    ('defence-services', 'leadership', 0),
    ('defence-services', 'physical-fitness', 1),
    ('defence-services', 'discipline', 2),
    ('defence-services', 'decision-making', 3),
    ('defence-services', 'teamwork', 4),
    ('defence-services', 'resilience', 5),
    ('defence-studies', 'research', 0),
    ('defence-studies', 'strategic-thinking', 1),
    ('defence-studies', 'analytical-thinking', 2),
    ('defence-studies', 'report-writing', 3),
    ('defence-studies', 'communication', 4);

-- No sort_order on career_industries.
INSERT INTO career_industries (career_slug, industry_slug) VALUES
    ('defence-services', 'aerospace-defence'),
    ('defence-services', 'government'),
    ('defence-services', 'government-of-india'),
    ('defence-studies', 'aerospace-defence'),
    ('defence-studies', 'research-and-development'),
    ('defence-studies', 'education'),
    ('defence-studies', 'defence-research-and-development-organisation');

DO $$
DECLARE n int;
BEGIN
    SELECT count(*) INTO n FROM careers
    WHERE slug IN ('defence-services', 'defence-studies') AND category_slug = 'defence';
    IF n <> 2 THEN RAISE EXCEPTION 'expected both new careers in defence, found %', n; END IF;

    -- The whole point: the two defence exams must no longer lead nowhere.
    SELECT count(*) INTO n FROM exams e
    WHERE e.category = 'Defence'
      AND NOT EXISTS (SELECT 1 FROM career_exams ce WHERE ce.exam_slug = e.slug);
    IF n > 0 THEN RAISE EXCEPTION '% Defence exam(s) still have no career linked', n; END IF;

    -- The completeness gate, same as V118, V120, V121 and V122.
    SELECT count(*) INTO n FROM careers c
    WHERE c.slug IN ('defence-services', 'defence-studies')
      AND (c.salary_min_lpa IS NULL
           OR (SELECT count(*) FROM career_degrees d    WHERE d.career_slug = c.slug) < 2
           OR (SELECT count(*) FROM career_exams e      WHERE e.career_slug = c.slug) < 1
           OR (SELECT count(*) FROM career_skills s     WHERE s.career_slug = c.slug) < 3
           OR (SELECT count(*) FROM career_industries i WHERE i.career_slug = c.slug) < 2);
    IF n > 0 THEN RAISE EXCEPTION '% new career(s) fall short of the completeness gate', n; END IF;

    SELECT count(*) INTO n FROM career_degrees cd
    WHERE cd.career_slug IN ('defence-services', 'defence-studies')
      AND cd.subject_slug IS NOT NULL
      AND NOT EXISTS (SELECT 1 FROM degree_subjects ds
                      WHERE ds.degree_slug = cd.degree_slug AND ds.subject_slug = cd.subject_slug);
    IF n > 0 THEN RAISE EXCEPTION '% degree row(s) name a degree/subject pair that does not exist', n; END IF;

    -- Military Service Pay is excluded from the range, so the reader has to be
    -- told it exists. If this highlight is edited away the range understates the
    -- career without anything saying so.
    SELECT count(*) INTO n FROM careers
    WHERE slug = 'defence-services'
      AND EXISTS (SELECT 1 FROM unnest(highlights) h WHERE h LIKE '%Military Service Pay%');
    IF n <> 1 THEN
        RAISE EXCEPTION 'defence-services must carry the highlight naming Military Service Pay, which its salary range excludes';
    END IF;

    SELECT count(*) INTO n FROM (
        SELECT career_slug, exam_slug FROM career_exams
        EXCEPT SELECT career_slug, exam_slug FROM exam_careers) x;
    IF n > 0 THEN RAISE EXCEPTION '% career_exams row(s) have no exam_careers mirror', n; END IF;
END $$;
