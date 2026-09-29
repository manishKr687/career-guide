-- Gives the five careers added in V120-V124 the employers they were missing.
--
-- Fifty of the catalog's fifty-five careers list specific employers as well as
-- sectors, and the career page's "Top Recruiters" section reads those employer
-- rows. The five careers added in the recent content batches linked sectors only,
-- so their pages have carried an empty Top Recruiters section since they were
-- created. That is my own gap from those migrations, not an inherited one.
--
--   commerce, economics                     V120
--   political-science                       V122
--   electrical-trades, welding-and-fabrication  V124
--
-- Every employer named below already exists in the catalog -- none is created
-- here. They were chosen as places a graduate of that field actually goes, not as
-- the largest brands available:
--
--   economics          The Reserve Bank recruits economists directly into its
--                      Department of Economic and Policy Research; NITI Aayog and
--                      the National Sample Survey Office are where government
--                      economic analysis is done; the Indian Statistical
--                      Institute is the research route; McKinsey stands for the
--                      economic-consulting route that absorbs many of the rest.
--
--   commerce           The Big Four are where commerce graduates overwhelmingly
--                      begin -- audit and tax -- and Grant Thornton for the tier
--                      below. Deliberately NOT the banks: banking is its own
--                      career in this catalog and already lists them, and
--                      duplicating them here would blur the distinction V120 drew
--                      between Commerce the discipline and Banking the field.
--
--   political-science  CSDS is the discipline's best-known research institute in
--                      India, NITI Aayog the policy route, and the Government of
--                      India the employer most of its graduates enter through the
--                      civil services.
--
--   electrical-trades  Power generation (NTPC, Tata Power), the EPC contractor
--                      that employs the most site electricians (L&T), and the
--                      equipment manufacturers whose panels and switchgear the
--                      trade actually works on (Havells, Schneider).
--
--   welding-and-fabrication  Heavy fabrication and steel: L&T for project sites,
--                      and the three steel producers whose plants run the largest
--                      welding shops in the country.
--
-- career_industries has no sort_order, unlike career_skills, so these are plain
-- inserts with nothing to re-densify.

INSERT INTO career_industries (career_slug, industry_slug) VALUES
    ('economics', 'reserve-bank-of-india'),
    ('economics', 'niti-aayog'),
    ('economics', 'national-sample-survey-office'),
    ('economics', 'indian-statistical-institute'),
    ('economics', 'mckinsey-company'),

    ('commerce', 'deloitte'),
    ('commerce', 'kpmg'),
    ('commerce', 'pwc'),
    ('commerce', 'ey'),
    ('commerce', 'grant-thornton-bharat'),

    ('political-science', 'centre-for-the-study-of-developing-societies'),
    ('political-science', 'niti-aayog'),
    ('political-science', 'government-of-india'),

    ('electrical-trades', 'ntpc'),
    ('electrical-trades', 'tata-power'),
    ('electrical-trades', 'larsen-toubro'),
    ('electrical-trades', 'havells-india'),
    ('electrical-trades', 'schneider-electric'),

    ('welding-and-fabrication', 'larsen-toubro'),
    ('welding-and-fabrication', 'tata-steel'),
    ('welding-and-fabrication', 'jsw-steel'),
    ('welding-and-fabrication', 'steel-authority-of-india');

DO $$
DECLARE n int; bare text;
BEGIN
    -- The five now have employers, not just sectors.
    SELECT count(*), string_agg(slug, ', ' ORDER BY slug) INTO n, bare
    FROM careers c
    WHERE c.slug IN ('commerce', 'economics', 'political-science', 'electrical-trades',
                     'welding-and-fabrication')
      AND NOT EXISTS (
          SELECT 1 FROM career_industries ci JOIN industries i ON i.slug = ci.industry_slug
          WHERE ci.career_slug = c.slug AND NOT i.is_sector);
    IF n > 0 THEN
        RAISE EXCEPTION '% of the five career(s) still have no employer: %', n, bare;
    END IF;

    -- And nothing in the catalog does. This is the check that should have existed
    -- when those five were added, and it is the reason to write it now rather
    -- than just fixing the rows: the same omission cannot repeat silently.
    SELECT count(*), string_agg(slug, ', ' ORDER BY slug) INTO n, bare
    FROM careers c
    WHERE NOT EXISTS (
        SELECT 1 FROM career_industries ci JOIN industries i ON i.slug = ci.industry_slug
        WHERE ci.career_slug = c.slug AND NOT i.is_sector);
    IF n > 0 THEN
        RAISE EXCEPTION '% career(s) have no employer and would show an empty Top Recruiters: %', n, bare;
    END IF;

    -- Every employer named above must be an employer, not a sector -- a sector
    -- linked here would render in Top Recruiters as though it were a company.
    SELECT count(*) INTO n FROM career_industries ci
    JOIN industries i ON i.slug = ci.industry_slug
    WHERE ci.career_slug IN ('commerce', 'economics', 'political-science', 'electrical-trades',
                             'welding-and-fabrication')
      AND i.is_sector
      AND i.slug IN ('reserve-bank-of-india', 'niti-aayog', 'deloitte', 'ntpc', 'tata-steel');
    IF n > 0 THEN RAISE EXCEPTION '% employer link(s) point at a sector row', n; END IF;
END $$;
