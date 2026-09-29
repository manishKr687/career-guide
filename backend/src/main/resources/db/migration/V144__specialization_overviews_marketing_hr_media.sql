-- Overviews for the Marketing, Human Resource Management and Journalism & Mass
-- Communication specializations. Eleventh batch; V134 explains rationale and
-- exclusions.
--
-- 17 rows: 6 under Marketing, 5 under Human Resource Management, 6 under
-- Journalism & Mass Communication.
--
-- THE THREE MARKETING CHANNEL SPECIALIZATIONS ARE NOT SYNONYMS, though they are
-- used as such in job adverts, so the overviews draw the line the industry
-- actually works to: Digital Marketing is the umbrella across owned, earned and
-- paid channels; Performance Marketing is paid acquisition judged on cost per
-- acquisition and return on ad spend; Content Marketing is earning attention
-- through material people choose to read, with search as its main distribution.
-- Brand Management and Product Marketing are separated the same way -- brand
-- equity over years, against one product's positioning and launch.
--
-- ADVERTISING SITS UNDER JOURNALISM & MASS COMMUNICATION here, not under
-- Marketing, and the overview is written from that side: the creative and agency
-- craft of making the campaign, rather than the client-side decision of what to
-- spend. The ASCI is named as the self-regulatory body whose code the work is
-- subject to.
--
-- LABOUR STATUTE IS NAMED, NOT SUMMARISED. Indian employment law is mid-
-- consolidation into the four labour codes, with the older Acts still operative
-- while they are brought into force in stages. The overviews name the statutes
-- that define the work and deliberately do not state which are in force today,
-- because that answer changes by notification and by state.
--
-- A NOTE ON THE PAY-CLAIM ASSERTION at the foot of this file, which rejects the
-- words salary, package, LPA and so on anywhere in an overview. Compensation &
-- Benefits is the one specialization whose subject IS pay, and it reads "market
-- pay surveys and benchmarking" rather than "salary surveys" purely to satisfy
-- that check. The phrasing is standard in the field, and keeping the assertion
-- absolute is worth more than the word: an exemption carved out here is the gap
-- through which an unsourced number would later arrive.

UPDATE specializations SET overview = v.overview
FROM (VALUES

-- ------------------------------------------------------------------- Marketing

('brand-management',
 'This specialization covers building and protecting a brand over years: brand positioning and identity, brand equity and how it is measured, brand architecture and portfolio decisions, extensions and their risks, repositioning and revitalisation, pricing and premium justification, packaging and design, and the coordination of every customer touchpoint so they say the same thing. It is the long-horizon discipline, distinct from launching any single product.'),

('content-marketing',
 'This specialization covers earning attention with material people choose to consume: audience research and content strategy, editorial planning and the content calendar, writing for the web, long-form, video, podcast and newsletter formats, search engine optimisation and keyword research as the primary distribution channel, distribution and repurposing, lead capture, and measurement through traffic, engagement and assisted conversion.'),

('digital-marketing',
 'This specialization covers marketing across digital channels as an integrated system: website and landing page experience, search engine optimisation and paid search, social media organic and paid, display and video, email and marketing automation, affiliate and influencer channels, and analytics and attribution across them. Campaign planning, budget allocation between channels and conversion rate optimisation are the recurring decisions.'),

('market-research',
 'This specialization covers finding out what customers actually think and do: problem definition and research design, secondary research, qualitative methods including depth interviews, focus groups and ethnography, survey and questionnaire design, sampling, scaling and measurement, fieldwork and data quality, statistical analysis including segmentation, factor and conjoint analysis, and reporting a finding in a form a business will act on.'),

('performance-marketing',
 'This specialization covers paid acquisition held to a numeric target: campaign structure and bidding on search, social and programmatic platforms, audience targeting and lookalikes, creative testing at volume, landing page and funnel optimisation, conversion tracking and attribution modelling, and management to cost per click, cost per acquisition, return on ad spend and lifetime value. Measurement discipline and incrementality testing are what distinguish it from spending budget.'),

('product-marketing',
 'This specialization covers connecting a specific product to its market: customer and competitor research, segmentation and positioning, messaging and value proposition, pricing and packaging input, go-to-market and launch planning, sales enablement material and competitive battlecards, analyst and customer references, and feeding market evidence back into the product roadmap. It sits between product management, sales and marketing and translates between them.'),

-- --------------------------------------------------- Human Resource Management

('compensation-and-benefits',
 'This specialization covers what people are paid and why: job analysis and evaluation, grade and pay structure design, market pay surveys and benchmarking, internal equity, variable pay and incentive scheme design, sales compensation, long-term incentives and employee stock options, and benefits including insurance and leave policy. Indian statutory components -- provident fund, gratuity, bonus and the Code on Wages framework -- and payroll governance are part of the subject.'),

('employee-relations',
 'This specialization covers the relationship between an employer and its workforce, individually and collectively: trade unions and recognition, collective bargaining and settlements, grievance procedure, discipline and the conduct of a domestic enquiry, misconduct and dismissal, industrial dispute resolution through conciliation, arbitration and adjudication, and workplace investigations including those required under the POSH Act 2013. The Industrial Disputes Act 1947 and the Industrial Relations Code frame it.'),

('hr-operations',
 'This specialization covers the administrative machinery of employment: the employee lifecycle from onboarding and documentation to transfer, confirmation and exit, HRIS data management and integrity, attendance and leave administration, payroll inputs and coordination, statutory registers, returns and compliance, policy administration and query resolution, and HR reporting and analytics. It is the function the rest of HR depends on, and accuracy is its whole value.'),

('learning-and-development',
 'This specialization covers building capability in an organisation: training needs analysis against competency frameworks, adult learning principles, instructional design through models such as ADDIE, choosing between classroom, on-the-job, blended and digital delivery, e-learning production and learning management systems, leadership and management development, coaching and mentoring programmes, and evaluation of effectiveness rather than of attendance.'),

('talent-acquisition',
 'This specialization covers finding and hiring the right people: workforce planning and role definition, sourcing through job boards, referrals, professional networks and direct search, employer branding, screening and structured interviewing, selection assessments and their validity, interview panel training, candidate experience, offer construction and negotiation, background verification, and campus recruitment. Applicant tracking systems and metrics such as time to fill and quality of hire manage the process.'),

-- ------------------------------------- Journalism & Mass Communication

('advertising',
 'This specialization covers making the campaign: consumer insight and the creative brief, concept development, copywriting for print, digital, audio and film, art direction and visual craft, campaign ideas that hold across media, media planning, buying and scheduling, production, and effectiveness measurement. Agency structure and the client relationship are part of the training, as is the self-regulatory code administered by the Advertising Standards Council of India.'),

('broadcasting',
 'This specialization covers television and radio as production disciplines: scripting for the ear and the screen, studio and field production, camera, lighting and sound, non-linear editing, packaging a story into a bulletin, anchoring, voice and presentation, live reporting and outside broadcast, and control room operation and running order. Programme and advertising codes and the constraints of live transmission shape the working practice.'),

('digital-journalism',
 'This specialization covers reporting for audiences who read on a phone: writing and structuring for the web, headline and search-aware framing, multimedia and visual storytelling, social media as both a source and a distribution channel, verification of user-generated content and open-source material, data journalism and visualisation, audience analytics, newsletters and podcasts, and fact-checking against misinformation. The speed-versus-accuracy tension is the discipline''s central ethical problem.'),

('journalism',
 'This specialization covers reporting as a craft: news values and judgement, beat reporting and source cultivation, interviewing, note-taking and accuracy, news writing structure, editing and headline writing, feature and long-form work, investigative method and document-based reporting, and photojournalism. Media law -- defamation, contempt of court, privacy, official secrets and the right to information -- and journalistic ethics around attribution and conflict of interest are treated as working knowledge.'),

('media-production',
 'This specialization covers making film, video and audio content end to end: scripting and storyboarding, budgeting and production scheduling, direction and working with performers, cinematography and lighting, location and studio sound, editing and post-production workflow, colour grading, graphics and visual effects basics, music and mixing, and the formats -- fiction, documentary, advertising, corporate and web series -- with their distribution routes.'),

('public-relations',
 'This specialization covers managing what an organisation is understood to be: stakeholder identification and communication strategy, media relations, press releases and press conferences, corporate and internal communication, spokesperson preparation, event and sponsorship communication, CSR and sustainability messaging, digital and influencer relations, and crisis communication planning and response. Evaluation beyond clipping counts -- share of voice, sentiment and outcome measures -- is part of the discipline.')

) AS v(slug, overview)
WHERE specializations.slug = v.slug;

DO $$
DECLARE n int; bad text;
BEGIN
    SELECT count(*) INTO n FROM specializations
    WHERE primary_career_slug IN ('marketing', 'human-resource-management',
                                  'journalism-and-mass-communication')
      AND overview IS NOT NULL AND overview <> '';
    IF n <> 17 THEN
        RAISE EXCEPTION 'expected 17 marketing/HR/media specializations with an overview, found % -- a slug did not match', n;
    END IF;

    SELECT count(*), string_agg(slug, ', ' ORDER BY slug) INTO n, bad
    FROM specializations
    WHERE primary_career_slug IN ('marketing', 'human-resource-management',
                                  'journalism-and-mass-communication')
      AND (overview IS NULL OR overview = '');
    IF n > 0 THEN
        RAISE EXCEPTION '% marketing/HR/media specialization(s) still have no overview: %', n, bad;
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
