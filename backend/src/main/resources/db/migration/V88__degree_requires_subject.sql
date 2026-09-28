-- Marks which qualifications take a subject.
--
-- V87 split field-of-study out into `subjects`. This column answers the
-- question that split creates: when an admin picks a degree, should a Subject
-- dropdown appear next to it?
--
--   requires_subject = true   "M.Sc" alone is incomplete -- M.Sc in WHAT?
--   requires_subject = false  "MBBS" is complete on its own.
--
-- The false cases are of three kinds, and they are false for different
-- reasons:
--
--   fused        MBBS, BDS, BAMS, BVSc & AH, BPT, B.Pharm, B.Arch, B.Ed --
--                the qualification and the field are one fact. "MBBS in
--                Medicine" is not something anyone says.
--   dual         BA LLB, BSc BEd, BCom LLB -- two qualifications earned
--                together, already fully specified by the pair itself.
--   vocational   GNM, ANM, D.El.Ed, BHM -- named for the occupation they
--                train for.
--
-- Note B.Tech M.Tech (Dual) IS true: it is a dual qualification, but you
-- still read it in a subject ("dual degree in Computer Science"). Being a
-- dual degree and taking a subject are independent properties.
--
-- This column is a UI hint, NOT a constraint. It cannot be enforced yet --
-- the link tables have no subject_slug column at all until V89, and the
-- existing rows carry no subject until V90 repoints them. Once that is done,
-- a CHECK tying the two together is the schema-enforced version and is the
-- right end state; leaving it as convention is how the problems this refactor
-- is fixing got here in the first place.

ALTER TABLE degrees ADD COLUMN requires_subject BOOLEAN NOT NULL DEFAULT FALSE;

UPDATE degrees SET requires_subject = TRUE WHERE slug IN (
    -- generic academic qualifications: the subject is the whole point
    'ba', 'b-sc', 'ma', 'msc', 'phd',
    -- engineering: the branch is the subject
    'b-tech', 'm-tech', 'b-eng', 'm-eng', 'b-tech-m-tech',
    -- commerce and management: specialisation-bearing
    'b-com', 'm-com', 'mba', 'pgdm',
    -- design and fine arts: discipline-bearing
    'b-des', 'm-des', 'bfa', 'mfa',
    -- medical postgraduate: the speciality is the subject
    'md', 'ms-surgery', 'dm', 'mch', 'mds',
    -- postgraduate law
    'llm',
    -- generic containers, always "<X> in <subject>"
    'diploma', 'certificate'
);

DO $$
DECLARE bad int;
BEGIN
    SELECT count(*) INTO bad FROM degrees WHERE requires_subject;
    IF bad <> 26 THEN
        RAISE EXCEPTION 'expected 26 subject-bearing degrees, found %', bad;
    END IF;

    -- The fused qualifications are the whole reason this is a per-degree flag
    -- rather than a blanket rule. If one of them ever flips to true, the
    -- distinction has been lost.
    SELECT count(*) INTO bad FROM degrees
    WHERE requires_subject
      AND slug IN ('mbbs', 'bds', 'bams', 'bhms', 'bums', 'bsms', 'bnys',
                   'bvsc-ah', 'mvsc', 'b-arch', 'm-arch', 'b-ed', 'm-ed',
                   'bpharm', 'mpharm', 'dpharm', 'pharmd', 'gnm', 'anm',
                   'bpt', 'mpt', 'bot', 'mot', 'bca', 'mca', 'llb');
    IF bad > 0 THEN
        RAISE EXCEPTION '% fused qualification(s) wrongly marked as requiring a subject', bad;
    END IF;

    -- Nothing that is itself a qualification-x-subject product should require
    -- a subject: those 62 rows are being removed, not annotated.
    SELECT count(*) INTO bad FROM degrees
    WHERE requires_subject
      AND (slug LIKE 'ba-%' OR slug LIKE 'bsc-%' OR slug LIKE 'ma-%'
           OR slug LIKE 'msc-%' OR slug LIKE 'phd-%');
    IF bad > 0 THEN
        RAISE EXCEPTION '% product row(s) wrongly marked as requiring a subject', bad;
    END IF;
END $$;
