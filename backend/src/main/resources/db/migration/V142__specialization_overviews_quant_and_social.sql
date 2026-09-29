-- Overviews for the Mathematics, Statistics, Psychology, Sociology and Public
-- Administration specializations. Ninth batch; V134 explains rationale and
-- exclusions.
--
-- 22 rows: 4 under Mathematics, 5 under Statistics, 5 under Psychology, 4 under
-- Sociology, 4 under Public Administration.
--
-- THE RCI IS NAMED FOR CLINICAL PSYCHOLOGY, because it is the fact that most
-- often surprises a student: practising as a clinical psychologist in India
-- requires registration with the Rehabilitation Council of India, which an MA in
-- Psychology alone does not confer -- the recognised route is an M.Phil in
-- Clinical Psychology at an RCI-approved centre. Counselling Psychology is not
-- regulated in the same way, and the two overviews say so, because a student
-- choosing between them is choosing between a licensed and an unlicensed path.
--
-- INDUSTRIAL AND ORGANIZATIONAL PSYCHOLOGY ARE ONE FIELD internationally, taught
-- as industrial-organizational psychology. Indian syllabi frequently split them,
-- so both pages exist here; rather than inventing a hard boundary the overviews
-- state the conventional emphasis of each and note that they are two halves of
-- the same subject.

UPDATE specializations SET overview = v.overview
FROM (VALUES

-- ----------------------------------------------------------------- Mathematics

('applied-mathematics',
 'This specialization covers mathematics used to model and solve problems outside mathematics: ordinary and partial differential equations, vector calculus, linear algebra and matrix methods, integral transforms, complex analysis, and optimisation and calculus of variations. Expect continuum mechanics, mathematical physics and mathematical biology as application areas, with the emphasis on formulating a real problem into tractable equations and interpreting what the solution means.'),

('computational-mathematics',
 'This specialization covers solving mathematical problems numerically when no closed form exists: floating point arithmetic and error analysis, root finding, interpolation and approximation, numerical linear algebra including direct and iterative solvers and eigenvalue methods, quadrature, numerical solution of differential equations by finite difference, finite element and spectral methods, and Monte Carlo simulation. Implementation and the stability and convergence of the algorithm are inseparable.'),

('financial-mathematics',
 'This specialization covers the mathematics of financial markets: probability and stochastic processes, Brownian motion and Ito calculus, the Black-Scholes framework and its assumptions, derivative pricing and hedging, binomial and lattice methods, interest rate and term structure models, portfolio theory and optimisation, and risk measures including value at risk. Expect numerical methods and Monte Carlo pricing, and calibration to market data.'),

('pure-mathematics',
 'This specialization covers mathematics pursued for its own structure: real and complex analysis, abstract algebra through groups, rings and fields, linear algebra, topology and metric spaces, measure theory, differential geometry and number theory. The subject matter is proof -- constructing and verifying rigorous argument -- and the training is in that discipline as much as in any particular body of results.'),

-- ------------------------------------------------------------------ Statistics

('applied-statistics',
 'This specialization covers using statistical method on real data: design of experiments and analysis of variance, regression and general linear models, categorical data analysis, survey sampling design and estimation, time series analysis and forecasting, multivariate methods, and non-parametric alternatives. The emphasis is on checking assumptions, diagnosing model failure and reporting uncertainty honestly, with work in R or a comparable environment throughout.'),

('biostatistics',
 'This specialization covers statistics as practised in medicine and public health: clinical trial design including randomisation, blinding, sample size and interim analysis, survival analysis and censoring, longitudinal and repeated measures data, logistic and Poisson regression for epidemiological studies, measures of risk and association, diagnostic test accuracy, meta-analysis, and the handling of missing data. Regulatory reporting standards frame much of the work.'),

('business-statistics',
 'This specialization covers quantitative method applied to commercial decisions: descriptive summary and data visualisation, probability and sampling, estimation and hypothesis testing, correlation and regression for prediction, index numbers, time series decomposition and forecasting for demand and sales, statistical quality control, and decision analysis under uncertainty. Interpretation for a non-technical audience is treated as part of the skill.'),

('data-analytics',
 'This specialization covers turning raw data into decisions: data acquisition and cleaning, exploratory analysis and visualisation, SQL querying, descriptive and diagnostic analysis, predictive modelling through regression, classification and clustering, dashboard and report building in a tool such as Power BI or Tableau, and A/B testing. It is the most tool-oriented member of this group, and defining the question well is more of the work than fitting the model.'),

('mathematical-statistics',
 'This specialization covers the theory that statistical practice rests on: probability spaces and measure-theoretic foundations, random variables and distribution theory, transformations and sampling distributions, modes of convergence and limit theorems, point and interval estimation with sufficiency, unbiasedness, efficiency and maximum likelihood, the Neyman-Pearson framework for testing, Bayesian inference, and decision theory. It is a proof-based course rather than a methods one.'),

-- ------------------------------------------------------------------ Psychology

('clinical-psychology',
 'This specialization covers the assessment and psychological treatment of mental disorder: psychopathology and diagnostic classification, clinical interviewing, psychometric and neuropsychological assessment, and evidence-based therapies including cognitive behavioural, behavioural and family approaches, with supervised clinical placement. In India, independent practice requires registration with the Rehabilitation Council of India, and the recognised route is an M.Phil in Clinical Psychology at an RCI-approved centre.'),

('counseling-psychology',
 'This specialization covers helping people through difficulty that is not necessarily disorder: the counselling relationship and core conditions, person-centred, cognitive behavioural and solution-focused approaches, career and educational guidance, grief, relationship and family counselling, crisis intervention, and group work. Ethics, confidentiality, boundaries and supervision are central. It is a distinct path from Clinical Psychology and is not regulated by the RCI in the same way.'),

('educational-psychology',
 'This specialization covers how people learn and why some struggle: cognitive and social development, theories of learning and motivation, intelligence and aptitude and their measurement, individual differences, specific learning disabilities such as dyslexia and their identification, classroom behaviour management, curriculum and instructional design, assessment and evaluation, and guidance and remedial support in a school setting.'),

('industrial-psychology',
 'This specialization covers psychology applied to work and the workforce: job analysis, recruitment and personnel selection, psychometric testing and assessment centres, performance appraisal, training needs analysis and evaluation, job satisfaction and engagement, occupational stress and safety, ergonomics and human factors. It is conventionally the selection, measurement and work-design half of what is internationally taught as one industrial-organizational field.'),

('organizational-psychology',
 'This specialization covers the behaviour of people in organisations: motivation and job design, group dynamics and team effectiveness, leadership, communication and influence, power and conflict, organisational culture and climate, change management and resistance, and organisation development interventions. It is conventionally the behaviour and culture half of the single industrial-organizational field, and overlaps with Industrial Psychology by design.'),

-- ------------------------------------------------------------------- Sociology

('rural-sociology',
 'This specialization covers the social organisation of village India: agrarian social structure, caste, kinship and land relations, the village as a community and its changing boundaries, panchayati raj and local power, rural stratification and mobility, agrarian change and the social consequences of agricultural technology, migration to towns, rural development programmes and their reception, and the position of women in rural households.'),

('social-policy',
 'This specialization covers how collective provision is designed and who it reaches: theories of welfare and social justice, poverty and inequality measurement, the policy cycle from problem definition to evaluation, and the substantive fields of education, health, housing, employment, food security and social protection. Expect study of India''s major welfare programmes and legislation, targeting versus universal provision, and implementation gaps between stated entitlement and delivered service.'),

('social-research',
 'This specialization covers producing evidence about society: research design and formulating a researchable question, sampling, and the quantitative repertoire of survey construction, scaling, statistical analysis and secondary data, alongside the qualitative one of interviewing, focus groups, ethnography, case study and content and discourse analysis. Expect mixed methods, reliability and validity, research ethics and informed consent, and analysis with SPSS, R or a qualitative coding tool.'),

('urban-sociology',
 'This specialization covers the city as a social form: urbanisation and migration, urban growth and spatial segregation, slums and informal settlement, housing and tenure insecurity, the informal economy and urban livelihoods, community and anonymity in city life, urban poverty and exclusion, crime and policing, urban governance and municipal politics, and the social consequences of redevelopment and displacement.'),

-- -------------------------------------------------------- Public Administration

('administrative-management',
 'This specialization covers running a public organisation: organisational structure, hierarchy and delegation, line and staff relationships, personnel administration from recruitment and training to discipline and service conditions, financial and materials administration, office procedure and records, coordination and control mechanisms, performance measurement, and administrative reform and e-governance. The Indian administrative system provides the working context throughout.'),

('governance',
 'This specialization covers how authority is exercised and held to account: the shift from government to governance and the role of non-state actors, decentralisation and local self-government, transparency and the right to information, accountability institutions including audit, vigilance and the ombudsman, citizen participation and service delivery charters, corruption and its control, administrative ethics, and e-governance as a means of changing the citizen-state interface.'),

('public-finance',
 'This specialization covers the government''s revenue and spending: public goods, externalities and the rationale for state provision, taxation and its incidence, direct and indirect tax structure including GST, non-tax revenue, public expenditure analysis, the budget cycle and legislative control, deficits and public debt, fiscal responsibility rules, and Indian fiscal federalism through the Finance Commission and centre-state transfers.'),

('public-policy',
 'This specialization covers how policy is made and whether it works: agenda setting and problem framing, models of the policy process, actors and institutions including the bureaucracy, legislature, courts, media and interest groups, policy instrument choice, implementation and why it fails, cost-benefit and regulatory impact analysis, and monitoring and evaluation. Expect case-based study of Indian sectoral policy and the use of evidence in decisions.')

) AS v(slug, overview)
WHERE specializations.slug = v.slug;

DO $$
DECLARE n int; bad text;
BEGIN
    SELECT count(*) INTO n FROM specializations
    WHERE primary_career_slug IN ('mathematics', 'statistics', 'psychology', 'sociology',
                                  'public-administration')
      AND overview IS NOT NULL AND overview <> '';
    IF n <> 22 THEN
        RAISE EXCEPTION 'expected 22 quant/social specializations with an overview, found % -- a slug did not match', n;
    END IF;

    SELECT count(*), string_agg(slug, ', ' ORDER BY slug) INTO n, bad
    FROM specializations
    WHERE primary_career_slug IN ('mathematics', 'statistics', 'psychology', 'sociology',
                                  'public-administration')
      AND (overview IS NULL OR overview = '');
    IF n > 0 THEN
        RAISE EXCEPTION '% quant/social specialization(s) still have no overview: %', n, bad;
    END IF;

    SELECT count(*), string_agg(slug, ', ' ORDER BY slug) INTO n, bad
    FROM specializations
    WHERE overview IS NOT NULL AND btrim(overview) = btrim(coalesce(description, ''));
    IF n > 0 THEN
        RAISE EXCEPTION '% overview(s) merely repeat the description: %', n, bad;
    END IF;

    SELECT count(*), string_agg(slug || ' (' || length(btrim(overview)) || ')', ', ' ORDER BY slug)
    INTO n, bad
    FROM specializations
    WHERE overview IS NOT NULL AND length(btrim(overview)) NOT BETWEEN 200 AND 800;
    IF n > 0 THEN
        RAISE EXCEPTION '% overview(s) fall outside 200-800 characters: %', n, bad;
    END IF;

    SELECT count(*), string_agg(slug, ', ' ORDER BY slug) INTO n, bad
    FROM specializations
    WHERE overview IS NOT NULL
      AND (overview ~* '\y(lpa|lakh|crore|salary|package|ctc)\y' OR overview LIKE '%₹%');
    IF n > 0 THEN
        RAISE EXCEPTION '% overview(s) contain a pay claim, which belongs in the salary columns: %', n, bad;
    END IF;
END $$;
