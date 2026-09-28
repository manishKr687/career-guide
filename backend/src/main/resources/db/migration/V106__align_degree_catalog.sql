-- Aligns the degree catalog with the canonical list: adds the 15 missing
-- qualifications and removes the 23 unreferenced ones that are not on it.
--
-- 84 -> 76 rows. Deliberately the SAFE half of the alignment: every row
-- deleted here has zero inbound references, so nothing cascades and no page
-- changes. 13 further rows are also absent from the list but ARE referenced
-- (52 references between them) and are left in place pending a decision --
-- see the bottom of this comment.
--
-- ADDED (15)
--
--   UG   BSW BLIS BPA BVoc BStat BMath
--   PG   MSW MLIS MJMC MPA MVoc MStat
--   Doc  DSc DLitt LLD
--
-- Slugs follow the existing acronym convention -- no dots or hyphens, same as
-- bjmc, bpt, boptom, baslp -- rather than the dotted style of b-sc/m-tech,
-- which is used only where the abbreviation itself carries dots.
--
-- requires_subject is set per degree on the V88 rule: true where the
-- qualification is incomplete without a field ("BPA in what?" -- Music,
-- Dance, Theatre), false where the name already IS the field (BSW is social
-- work; BStat is statistics). DSc and DLitt are higher doctorates awarded in
-- a named discipline, so both take a subject; LLD does not, being law by
-- definition.
--
-- REMOVED (23), all with zero references
--
--   ANM, D.El.Ed, Pharm.D, Post Basic B.Sc Nursing, BFSc, BNYS, MASLP, MOT,
--   DM, MCh, BBM, BMM, BMS, MMS, PGDM, BPES,
--   BA BEd, BBA LLB, BCom LLB, BSc BEd, BSc LLB,
--   Master of Journalism, Master of Mass Communication
--
-- Two notes on that set. First, five integrated dual degrees go (BA BEd, BBA
-- LLB, BCom LLB, BSc BEd, BSc LLB) while BA LLB stays -- not because the list
-- treats them differently, but because BA LLB has 2 live references and this
-- migration only removes unreferenced rows. That asymmetry is temporary and
-- resolves whichever way the remaining 13 are decided.
--
-- Second, DM and MCh are real super-speciality medical qualifications and
-- Pharm.D is a real doctorate. They are removed because they are not on the
-- list and nothing points at them -- easily re-added if that was an
-- oversight, since re-adding an unreferenced row costs nothing.
--
-- STILL PRESENT, absent from the list but referenced (not touched here):
--   Diploma (25), Certificate (7), B.Tech M.Tech(Dual) (7), BA LLB (2),
--   BHM (2), MD (2), BHMCT, BTTM, MTTM, D.Pharm, GNM, MS,
--   Master of Hotel Management (1 each)
-- Deleting Diploma in particular would empty the After-10th polytechnic
-- feature (V98) and the Vocational stream (V92), so it needs a deliberate
-- call rather than a list diff.

INSERT INTO degrees (slug, title, description, icon, preparation_strategy, level, category_slug, requires_subject) VALUES
    ('bsw', 'BSW',
     'A 3-year undergraduate degree in Social Work covering community organisation, case work, social policy and supervised fieldwork -- the standard route into NGO, development-sector and welfare roles.',
     'users', 'Admission is usually 12th-marks-based or through a university entrance test; any stream qualifies.',
     'Undergraduate', 'arts-humanities', false),

    ('blis', 'BLIS',
     'A 1-year professional degree in Library and Information Science covering cataloguing, classification, information retrieval and digital library systems, taken after a bachelor''s.',
     'book', 'Entry is through a university entrance test; a bachelor''s degree in any discipline is required.',
     'Undergraduate', 'arts-humanities', false),

    ('bpa', 'BPA',
     'A 3-4 year undergraduate degree in the Performing Arts, specialising in one discipline such as music, dance or theatre, combining practice, theory and performance.',
     'palette', 'Admission is by audition alongside 12th marks at most universities.',
     'Undergraduate', 'design-creative', true),

    ('bvoc', 'BVoc',
     'A 3-year skill-focused undergraduate degree built around a specific trade or industry, with heavier practical and on-the-job components than a conventional bachelor''s.',
     'brief', 'Admission is largely 12th-marks-based; programmes are offered under the UGC''s vocational education framework.',
     'Undergraduate', 'skilled-trades', true),

    ('bstat', 'BStat',
     'A 3-year undergraduate degree in Statistics covering probability, inference, stochastic processes and statistical computing -- offered at a small number of specialist institutes.',
     'chart', 'Entry is through a dedicated entrance test; strong 12th-level Mathematics is essential.',
     'Undergraduate', 'science-research', false),

    ('bmath', 'BMath',
     'A 3-year undergraduate degree in Mathematics covering analysis, algebra, topology and probability, aimed at students heading into research or academia.',
     'chart', 'Entry is through a dedicated entrance test; strong 12th-level Mathematics is essential.',
     'Undergraduate', 'science-research', false),

    ('msw', 'MSW',
     'A 2-year postgraduate degree in Social Work specialising in a field such as medical and psychiatric social work, community development or human resources, with substantial fieldwork.',
     'users', 'Entry is through university entrance tests; a bachelor''s in any discipline is normally accepted.',
     'Postgraduate', 'arts-humanities', false),

    ('mlis', 'MLIS',
     'A 1-2 year postgraduate degree in Library and Information Science, deepening information management, digital archives and research methods beyond the BLIS.',
     'book', 'Entry is through a university entrance test, normally requiring a BLIS.',
     'Postgraduate', 'arts-humanities', false),

    ('mjmc', 'MJMC',
     'A 2-year postgraduate degree in Journalism and Mass Communication covering reporting, editing, media law, production and strategic communication.',
     'mega', 'Entry is through university entrance tests or CUET-PG.',
     'Postgraduate', 'media-communication', false),

    ('mpa', 'MPA',
     'A 2-year postgraduate degree in the Performing Arts, deepening one discipline through advanced practice, repertoire and research.',
     'palette', 'Admission is by audition alongside an entrance test; a BPA or equivalent training is expected.',
     'Postgraduate', 'design-creative', true),

    ('mvoc', 'MVoc',
     'A 2-year skill-focused postgraduate degree extending a vocational specialisation, with industry placement built into the programme.',
     'brief', 'Entry normally requires a B.Voc or a related bachelor''s in the same trade.',
     'Postgraduate', 'skilled-trades', true),

    ('mstat', 'MStat',
     'A 2-year postgraduate degree in Statistics covering advanced inference, multivariate analysis, design of experiments and statistical computing.',
     'chart', 'Entry is through a dedicated entrance test; a strong mathematics or statistics background is required.',
     'Postgraduate', 'science-research', false),

    ('dsc', 'DSc',
     'A higher doctorate in the sciences, awarded for a substantial published body of original research well beyond PhD level.',
     'flask', 'Not an admission-based programme: candidates submit an existing body of published work for assessment, usually years after a PhD.',
     'Doctoral', 'science-research', true),

    ('dlitt', 'DLitt',
     'A higher doctorate in the humanities, awarded for a substantial published body of original scholarship well beyond PhD level.',
     'book', 'Not an admission-based programme: candidates submit an existing body of published work for assessment, usually years after a PhD.',
     'Doctoral', 'arts-humanities', true),

    ('lld', 'LLD',
     'A higher doctorate in Law, awarded for a substantial published body of original legal scholarship well beyond PhD level.',
     'scale', 'Not an admission-based programme: candidates submit an existing body of published work for assessment, usually years after a PhD or LLM.',
     'Doctoral', 'law', false)
ON CONFLICT DO NOTHING;

-- Refuse to run if any of the 23 has gained a reference since this was
-- written. Every FK into `degrees` is ON DELETE CASCADE, so a stale
-- assumption here deletes live links silently rather than failing.
DO $$
DECLARE bad int;
BEGIN
    SELECT count(*) INTO bad FROM (VALUES
        ('anm'), ('d-el-ed'), ('pharmd'), ('post-basic-bsc-nursing'), ('bfsc'),
        ('bnys'), ('maslp'), ('mot'), ('dm'), ('mch'), ('bbm'), ('bmm'),
        ('bms'), ('mms'), ('pgdm'), ('bpes'), ('ba-bed'), ('bba-llb'),
        ('bcom-llb'), ('bsc-bed'), ('bsc-llb'), ('m-journalism'),
        ('m-mass-communication')
    ) AS v(slug)
    WHERE EXISTS (SELECT 1 FROM career_degrees        x WHERE x.degree_slug = v.slug)
       OR EXISTS (SELECT 1 FROM college_degrees       x WHERE x.degree_slug = v.slug)
       OR EXISTS (SELECT 1 FROM degree_exams          x WHERE x.degree_slug = v.slug)
       OR EXISTS (SELECT 1 FROM degree_skills         x WHERE x.degree_slug = v.slug)
       OR EXISTS (SELECT 1 FROM degree_resources      x WHERE x.degree_slug = v.slug)
       OR EXISTS (SELECT 1 FROM college_career_degrees x WHERE x.degree_slug = v.slug)
       OR EXISTS (SELECT 1 FROM exam_career_degrees   x WHERE x.degree_slug = v.slug)
       OR EXISTS (SELECT 1 FROM degree_subjects       x WHERE x.degree_slug = v.slug);
    IF bad > 0 THEN
        RAISE EXCEPTION '% of the 23 rows marked unreferenced now have references; refusing to cascade them away', bad;
    END IF;
END $$;

DELETE FROM degrees WHERE slug IN (
    'anm', 'd-el-ed', 'pharmd', 'post-basic-bsc-nursing', 'bfsc', 'bnys',
    'maslp', 'mot', 'dm', 'mch', 'bbm', 'bmm', 'bms', 'mms', 'pgdm', 'bpes',
    'ba-bed', 'bba-llb', 'bcom-llb', 'bsc-bed', 'bsc-llb',
    'm-journalism', 'm-mass-communication'
);

DO $$
DECLARE bad int;
BEGIN
    SELECT count(*) INTO bad FROM degrees;
    IF bad <> 76 THEN
        RAISE EXCEPTION 'expected 76 degrees, found %', bad;
    END IF;

    SELECT count(*) INTO bad FROM (VALUES
        ('bsw'), ('blis'), ('bpa'), ('bvoc'), ('bstat'), ('bmath'),
        ('msw'), ('mlis'), ('mjmc'), ('mpa'), ('mvoc'), ('mstat'),
        ('dsc'), ('dlitt'), ('lld')
    ) AS v(slug)
    WHERE NOT EXISTS (SELECT 1 FROM degrees d WHERE d.slug = v.slug);
    IF bad > 0 THEN
        RAISE EXCEPTION '% of the 15 new degrees were not created', bad;
    END IF;

    -- Icons must already be in the rendered vocabulary; a new name here shows
    -- nothing on the page.
    SELECT count(*) INTO bad FROM degrees d
    WHERE d.slug IN ('bsw','blis','bpa','bvoc','bstat','bmath','msw','mlis',
                     'mjmc','mpa','mvoc','mstat','dsc','dlitt','lld')
      AND NOT EXISTS (SELECT 1 FROM degrees o WHERE o.icon = d.icon AND o.slug <> d.slug);
    IF bad > 0 THEN
        RAISE EXCEPTION '% new degree(s) use an icon nothing else uses', bad;
    END IF;

    -- Nothing may have lost its education to the delete.
    SELECT count(*) INTO bad FROM careers c
    WHERE NOT EXISTS (SELECT 1 FROM career_degrees cd WHERE cd.career_slug = c.slug);
    IF bad > 0 THEN
        RAISE EXCEPTION '% career(s) lost their education', bad;
    END IF;

    SELECT count(*) INTO bad FROM degree_subjects ds
    WHERE NOT EXISTS (SELECT 1 FROM degrees d WHERE d.slug = ds.degree_slug);
    IF bad > 0 THEN
        RAISE EXCEPTION '% degree/subject pair(s) were orphaned', bad;
    END IF;
END $$;
