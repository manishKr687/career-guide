-- Overviews for the Finance, Accounting and Business Administration
-- specializations. Tenth batch; V134 explains rationale and exclusions.
--
-- 17 rows: 7 under Finance, 5 under Accounting, 5 under Business Administration.
--
-- INDIAN STATUTE AND PROFESSIONAL BODIES ARE NAMED where they define the work --
-- the Companies Act 2013 and the ICAI's auditing standards, the Income Tax Act
-- 1961 and GST, SEBI's registered investment adviser regime. As everywhere in
-- this series the institution is named and no rate, threshold, slab or limit is
-- quoted: those change every Finance Act and a stale number on a career page is
-- worse than no number.
--
-- FINANCIAL PLANNING AND WEALTH MANAGEMENT are separated by who is served rather
-- than by technique: financial planning is the process applied to an ordinary
-- household's goals, wealth management is the advisory practice built around
-- clients with substantial assets, and it adds estate, succession and tax
-- structuring on top. The overviews say which is which because the two job
-- descriptions differ far more than the two syllabi do.

UPDATE specializations SET overview = v.overview
FROM (VALUES

-- --------------------------------------------------------------------- Finance

('corporate-finance',
 'This specialization covers the financial decisions a company makes: capital budgeting and project appraisal by NPV and IRR, cost of capital and the capital structure question, dividend policy, working capital and cash conversion, business valuation by discounted cash flow and multiples, raising equity and debt, and mergers, acquisitions and restructuring. Financial statement analysis and forecast modelling underpin all of it.'),

('financial-analysis',
 'This specialization covers reading a business through its numbers: financial statement analysis and ratio interpretation, quality of earnings and the detection of accounting distortion, cash flow analysis, forecasting and three-statement financial modelling, valuation, scenario and sensitivity analysis, industry and competitive assessment, and equity and credit research writing. The output is a defensible recommendation, so building and stress-testing the model is the core skill.'),

('financial-planning',
 'This specialization covers organising an individual or household''s money around their goals: cash flow and budgeting, emergency provision, debt management, goal-based investment planning across horizons, risk profiling and asset allocation, life and health insurance needs analysis, retirement planning and pension products, tax-efficient investing, and estate and nomination basics. In India the advisory role is governed by SEBI''s investment adviser regulations, with the CFP certification widely held.'),

('fintech',
 'This specialization covers technology reshaping financial services: digital payments and India''s UPI and account aggregator infrastructure, lending platforms and alternative credit scoring, neobanking, wealthtech and robo-advisory, insurtech, blockchain and digital assets, and the use of machine learning in fraud detection and underwriting. Expect the regulatory layer to be treated as part of the subject -- RBI and SEBI oversight, KYC obligations and data protection.'),

('investment-banking',
 'This specialization covers advising on and executing large financial transactions: mergers and acquisitions from target screening through valuation, due diligence and negotiation to closing, equity capital markets and the IPO process, debt issuance, leveraged and structured finance, and restructuring. Expect comparable company and precedent transaction analysis, DCF and LBO modelling, and the preparation of pitch books and information memoranda.'),

('risk-management',
 'This specialization covers identifying and containing financial loss: market risk and value at risk, credit risk measurement, default probability and exposure, liquidity risk, operational risk and its loss event categories, model risk, and hedging with derivatives. Expect stress testing and scenario analysis, the Basel framework for banks and the regulatory capital it drives, and enterprise risk management as the organisational wrapper around the quantitative work.'),

('wealth-management',
 'This specialization covers advising clients with substantial assets: portfolio construction and asset allocation across equity, debt, real assets and alternatives, manager and product selection, performance measurement and attribution, tax-aware investing, estate and succession planning including wills and trusts, philanthropic and family office structures, and the relationship management the business runs on. It extends financial planning into structuring rather than replacing it.'),

-- ------------------------------------------------------------------ Accounting

('auditing',
 'This specialization covers independently examining whether financial statements are true and fair: audit planning and risk assessment, materiality, understanding and testing internal control, substantive procedures and sampling, audit evidence and documentation, going concern assessment, and forming and reporting the opinion. Indian statutory audit is conducted under the Companies Act 2013 and the auditing standards issued by the ICAI, alongside internal, tax and forensic audit as distinct engagements.'),

('financial-accounting',
 'This specialization covers recording transactions and producing the statements external users rely on: the accounting cycle and double entry, accrual concepts, revenue recognition, inventory and fixed asset accounting including depreciation and impairment, provisions and contingencies, leases, and the preparation of the balance sheet, profit and loss account and cash flow statement. Consolidation of group accounts and reporting under Ind AS complete it.'),

('forensic-accounting',
 'This specialization covers accounting applied to suspected wrongdoing: fraud schemes and the conditions that enable them, asset misappropriation, financial statement manipulation and the red flags that reveal it, investigative planning and interviewing, evidence gathering and chain of custody, digital forensics and data analytics over large transaction sets, quantification of loss, and report writing and expert testimony that will withstand cross-examination.'),

('management-accounting',
 'This specialization covers accounting for internal decisions rather than external reporting: cost classification and behaviour, job, process and activity-based costing, marginal costing and CVP analysis, relevant costing for make-or-buy and pricing decisions, budgeting and budgetary control, standard costing and variance analysis, responsibility accounting and transfer pricing, and performance measurement including the balanced scorecard.'),

('taxation',
 'This specialization covers the computation and administration of tax in India: direct tax under the Income Tax Act 1961 -- residence, the heads of income, deductions, set-off and carry forward, assessment procedure, TDS and advance tax -- and indirect tax under GST, covering supply, place and time of supply, input tax credit, returns and refunds. Corporate tax, capital gains, transfer pricing, international taxation and tax planning within the law complete it.'),

-- ------------------------------------------------------- Business Administration

('business-analytics',
 'This specialization covers using data to make business decisions: framing a business problem as an analytical one, data preparation and SQL, descriptive analysis and visualisation, predictive modelling by regression, classification and clustering, forecasting, optimisation and prescriptive methods, and experimentation. Expect application across marketing, operations, finance and HR, and emphasis on communicating a result to decision-makers who will not read the model.'),

('entrepreneurship',
 'This specialization covers starting and building a venture: opportunity identification and customer discovery, business model design, market sizing and competitive analysis, minimum viable product and iteration, unit economics and financial projection, founding team and equity, funding routes from bootstrapping through angel and venture capital to debt, legal structure and compliance in India, and scaling. Case study and live venture work carry much of the teaching.'),

('international-business',
 'This specialization covers operating across borders: theories of trade and foreign direct investment, entry mode choice from exporting through licensing and joint ventures to wholly owned subsidiaries, export-import procedure and documentation, trade finance and letters of credit, tariffs, trade agreements and the WTO framework, foreign exchange exposure and hedging, global supply chains, and managing across differing legal and cultural systems.'),

('operations',
 'This specialization covers producing and delivering goods and services efficiently: process design and analysis, capacity planning, facility location and layout, forecasting and aggregate planning, inventory management, scheduling, quality management and Six Sigma, lean principles, supply chain coordination, service operations, and project management. It is the management-level view of the same ground Industrial Engineering treats analytically.'),

('strategy',
 'This specialization covers deciding what a business should do and why it will work: industry and competitive analysis, the resource-based view and sustainable advantage, generic and business-level strategy, corporate strategy including diversification, vertical integration and the portfolio, mergers, alliances and divestment, international strategy, innovation and disruption, and the execution problem of aligning structure, incentives and culture behind a chosen direction.')

) AS v(slug, overview)
WHERE specializations.slug = v.slug;

DO $$
DECLARE n int; bad text;
BEGIN
    SELECT count(*) INTO n FROM specializations
    WHERE primary_career_slug IN ('finance', 'accounting', 'business-administration')
      AND overview IS NOT NULL AND overview <> '';
    IF n <> 17 THEN
        RAISE EXCEPTION 'expected 17 finance/business specializations with an overview, found % -- a slug did not match', n;
    END IF;

    SELECT count(*), string_agg(slug, ', ' ORDER BY slug) INTO n, bad
    FROM specializations
    WHERE primary_career_slug IN ('finance', 'accounting', 'business-administration')
      AND (overview IS NULL OR overview = '');
    IF n > 0 THEN
        RAISE EXCEPTION '% finance/business specialization(s) still have no overview: %', n, bad;
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
