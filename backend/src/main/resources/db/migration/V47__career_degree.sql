-- Adds a real one-to-many relationship between Degree and Career: one
-- Degree (e.g. B.Tech) naturally covers many careers (every engineering
-- career), while each Career realistically has at most one primary degree
-- path -- so the FK lives on the "many" side, careers.degree_slug, exactly
-- like careers.branch_slug (V23) and careers.category_slug. Nullable, same
-- reasoning as branch_slug: not every career has one yet.
--
-- This replaces the shared-entrance-exam heuristic added for the "Explore
-- Degrees" link (career page -> filtered /degrees) with a real relation
-- wherever the catalog supports it; the frontend keeps that heuristic only
-- as a fallback for careers left NULL here.
--
-- Backfill below is deliberately conservative: a career only gets a
-- degree_slug when its `education` text names exactly ONE of the 10
-- existing degree types (b-tech, diploma, b-ed, mba, mca, b-sc, b-com,
-- bba, phd, certificate) as the clear entry-level path. Left NULL when:
--   - `education` says "Any degree" / "Any bachelor's degree" / "Any
--     background" (no specific degree at all -- army-officer, bank-po,
--     business-analyst, digital-marketing-manager, entrepreneur,
--     hr-manager, ias-officer, ips-officer, product-manager,
--     sustainability-consultant)
--   - `education` genuinely offers multiple equally-valid entry paths
--     (data-analyst: B.Com/BBA/B.Tech; data-scientist: B.Tech/B.Sc/MCA;
--     ibps-it-officer & sebi-grade-a-officer-it: B.Tech/MCA;
--     investment-banker: B.Com/BBA; nurse: B.Sc Nursing/GNM;
--     psychologist: B.A./B.Sc; rrb-junior-engineer: Diploma/B.Tech;
--     ux-designer: B.Des/any degree) -- picking one would be a guess
--   - `education` names a degree type this catalog doesn't have at all
--     (dentist: BDS; doctor-mbbs: MBBS; historian & journalist: B.A.;
--     judge & lawyer: LLB; pharmacist: B.Pharm; hotel-manager: BHM;
--     graphic-designer: B.Des; company-secretary: no degree, straight
--     into ICSI after 12th; electrician & plumber: ITI trade diploma,
--     a different credential from this catalog's polytechnic "diploma")
--
-- The 24 careers below all name exactly one of this catalog's degree
-- types as their clear entry path, even where `education` also lists a
-- specific major/specialization or a later postgraduate step.

ALTER TABLE careers ADD COLUMN degree_slug VARCHAR(64) REFERENCES degrees(slug);


UPDATE careers SET degree_slug = 'b-tech' WHERE slug IN (
    'aerospace-engineer', 'ai-ml-engineer', 'biomedical-engineer', 'chemical-engineer',
    'civil-engineer', 'cloud-architect', 'computer-science-engineer', 'cybersecurity-analyst',
    'electrical-engineer', 'environmental-engineer', 'isro-scientist-engineer', 'marine-engineer',
    'mechanical-engineer', 'mechatronics-engineer', 'mining-engineer', 'robotics-engineer',
    'software-engineer'
);

UPDATE careers SET degree_slug = 'b-sc' WHERE slug IN (
    'agricultural-scientist'
);

UPDATE careers SET degree_slug = 'b-com' WHERE slug IN (
    'chartered-accountant'
);

UPDATE careers SET degree_slug = 'b-ed' WHERE slug IN (
    'school-principal', 'school-teacher'
);

UPDATE careers SET degree_slug = 'phd' WHERE slug IN (
    'professor', 'research-scientist'
);

UPDATE careers SET degree_slug = 'certificate' WHERE slug IN (
    'fitness-trainer'
);
