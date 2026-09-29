-- Overviews for the Law and Architecture specializations. Twelfth batch; V134
-- explains rationale and exclusions.
--
-- 14 rows: 9 under Law, 5 under Architecture.
--
-- THE CRIMINAL LAW OVERVIEW NAMES THE 2023 STATUTES. The Bharatiya Nyaya
-- Sanhita, Bharatiya Nagarik Suraksha Sanhita and Bharatiya Sakshya Adhiniyam
-- replaced the Indian Penal Code 1860, the Code of Criminal Procedure 1973 and
-- the Indian Evidence Act 1872 with effect from 1 July 2024. A criminal law page
-- that still says "IPC" is describing a syllabus that no longer exists, and this
-- is the single most consequential thing a law aspirant reading it could be told
-- wrongly. Both old and new are named, because the transitional cases are taught
-- and offences committed before the commencement date are still tried under the
-- old Code.
--
-- LABOUR LAW IS DESCRIBED AS MID-CONSOLIDATION, for the same reason as in V144:
-- the four labour codes subsume dozens of earlier Acts and are being brought into
-- force in stages, so the honest statement is that both layers are studied. No
-- claim is made here about which provisions are operative today.
--
-- INTERIOR ARCHITECTURE AND INTERIOR DESIGN both exist in this catalogue, under
-- Architecture and under Design respectively. The distinction is real and worth
-- stating: interior architecture concerns permanent spatial and structural
-- intervention in an existing building and is practised within the architectural
-- regulatory framework, while interior design under Design is oriented to
-- furnishing, finishes and the visual scheme. Students conflate them constantly.
--
-- STATUTES ARE NAMED, NEVER PARAPHRASED. No section, limitation period, rate,
-- penalty or threshold appears in any overview below.

UPDATE specializations SET overview = v.overview
FROM (VALUES

-- -------------------------------------------------------------------------- Law

('civil-law',
 'This specialization covers private disputes between persons and the remedies for them: the law of contract under the Indian Contract Act 1872 and its specific relief, tort and negligence, property law including transfer, easements and possession, family law across the personal law systems, succession, and trusts. Procedure is inseparable from it -- pleadings, jurisdiction and limitation under the Code of Civil Procedure 1908 -- along with evidence, execution of decrees and arbitration and mediation as alternatives to trial.'),

('constitutional-law',
 'This specialization covers the document that limits every other law: the preamble and its interpretation, fundamental rights and their reasonable restrictions, directive principles and fundamental duties, the federal distribution of legislative power, the executive and legislature, judicial review and the writ jurisdiction of the High Courts and Supreme Court, emergency provisions, and constitutional amendment with the basic structure doctrine. The subject is taught through its landmark judgments.'),

('corporate-law',
 'This specialization covers the law governing companies: incorporation, corporate personality and the lifting of the veil, share capital and securities, directors and their duties, board process and general meetings, related party transactions, audit and the statutory framework of corporate governance under the Companies Act 2013, and reconstruction, mergers and amalgamations. Securities regulation by SEBI, insolvency under the IBC 2016 and competition law form the surrounding regime.'),

('criminal-law',
 'This specialization covers offences against the state and the person and the process of trying them. India''s criminal law was recodified with effect from 1 July 2024: the Bharatiya Nyaya Sanhita replaced the Indian Penal Code 1860, the Bharatiya Nagarik Suraksha Sanhita replaced the Code of Criminal Procedure 1973, and the Bharatiya Sakshya Adhiniyam replaced the Indian Evidence Act 1872. Expect substantive offences, general defences, investigation and arrest, bail, charge and trial, sentencing, and criminology and victimology.'),

('cyber-law',
 'This specialization covers law applied to computers, networks and data: the Information Technology Act 2000 and its amendments, offences including unauthorised access, identity theft and obscenity, intermediary liability and the conditions of safe harbour, electronic records, digital signatures and the admissibility of electronic evidence, e-contracts and e-commerce, and personal data protection under the Digital Personal Data Protection Act 2023. Jurisdiction over conduct that crosses borders is a recurring difficulty.'),

('environmental-law',
 'This specialization covers the legal protection of the environment: the Water Act 1974, Air Act 1981 and the Environment (Protection) Act 1986 with the rules made under it, forest and wildlife legislation, the environmental impact assessment and clearance process, and the pollution control boards as regulators. Expect the judicially developed principles -- polluter pays, precautionary, public trust and absolute liability -- adjudication before the National Green Tribunal, and the climate and international law dimension.'),

('intellectual-property-law',
 'This specialization covers rights in intangible creations: patents and the patentability requirements and exclusions under the Patents Act 1970, trademarks, passing off and deceptive similarity, copyright in literary, artistic, musical and software works with moral rights and fair dealing, industrial designs, geographical indications, plant varieties, trade secrets and confidential information. Prosecution and opposition procedure, licensing and assignment, infringement remedies and the TRIPS framework complete it.'),

('labour-law',
 'This specialization covers the legal relationship of employment, individual and collective: conditions of work, wages, hours, safety and welfare, social security through provident fund, insurance and gratuity, industrial relations including unions, strikes, lay-off and retrenchment, and dispute adjudication. India is mid-consolidation of this field into the four labour codes on wages, industrial relations, social security and occupational safety, so both the codes and the earlier Acts they subsume are studied.'),

('tax-law',
 'This specialization covers the law of taxation and how it is contested: direct tax under the Income Tax Act 1961 -- charge, residence, heads of income, exemptions and deductions, assessment, reassessment, penalties and prosecution -- and indirect tax under the GST legislation, along with customs. Expect the appellate hierarchy from the Commissioner (Appeals) and Tribunal up to the High Courts and Supreme Court, the line between avoidance and evasion, GAAR, treaty interpretation and transfer pricing.'),

-- --------------------------------------------------------------- Architecture

('architectural-design',
 'This specialization is the core of an architecture programme and is taught through the design studio: developing a brief, reading and responding to a site and climate, space planning and circulation, form, proportion and light, structural and material logic, and detailing to the point where a building can be built. Expect hand drawing, technical drafting, physical modelling and CAD and BIM tools, and design within the National Building Code and local development byelaws.'),

('interior-architecture',
 'This specialization covers permanent intervention in the interior of a building: spatial reconfiguration and adaptive reuse of existing structures, partition and non-structural versus structural alteration, space planning, lighting and acoustic design, materials and finishes and their detailing, integration of services including HVAC, electrical and plumbing, and fire safety and egress compliance. It sits within architectural practice, unlike Interior Design under the Design career, which is oriented to furnishing and the visual scheme.'),

('landscape-architecture',
 'This specialization covers the design of outdoor space: site analysis, grading, contouring and surface drainage, planting design and the horticultural knowledge behind it, hardscape materials and detailing, water bodies and irrigation, and the programming of parks, campuses, plazas, streetscapes and residential landscapes. Expect ecological restoration, native and climate-appropriate planting, storm water management and the treatment of landscape as infrastructure rather than decoration.'),

('sustainable-architecture',
 'This specialization covers designing buildings that need less: climate analysis and orientation, passive solar design, shading and fenestration, natural ventilation and stack effect, daylighting, thermal comfort and envelope performance, insulation and thermal mass, low embodied carbon and local materials, rainwater harvesting and wastewater reuse, and renewable integration. Energy simulation supports the design, and the Indian rating and code frameworks -- GRIHA, IGBC and the ECBC -- define what must be demonstrated.'),

('urban-planning',
 'This specialization covers the planned development of towns and cities: land use survey and analysis, master and development plan preparation, zoning and development control regulations, density and floor area regulation, transport and infrastructure planning, housing and slum upgrading, urban design at the neighbourhood scale, and regional and metropolitan planning. Expect GIS and spatial analysis, participatory planning method, and the Indian statutory framework of development authorities and municipal bodies.')

) AS v(slug, overview)
WHERE specializations.slug = v.slug;

DO $$
DECLARE n int; bad text;
BEGIN
    SELECT count(*) INTO n FROM specializations
    WHERE primary_career_slug IN ('law', 'architecture')
      AND overview IS NOT NULL AND overview <> '';
    IF n <> 14 THEN
        RAISE EXCEPTION 'expected 14 law/architecture specializations with an overview, found % -- a slug did not match', n;
    END IF;

    SELECT count(*), string_agg(slug, ', ' ORDER BY slug) INTO n, bad
    FROM specializations
    WHERE primary_career_slug IN ('law', 'architecture')
      AND (overview IS NULL OR overview = '');
    IF n > 0 THEN
        RAISE EXCEPTION '% law/architecture specialization(s) still have no overview: %', n, bad;
    END IF;

    -- The recodification is the fact most likely to be silently reverted by a
    -- later well-meaning edit that "corrects" the new names back to the familiar
    -- ones. Pinned here so that edit fails loudly instead.
    SELECT count(*) INTO n FROM specializations
    WHERE slug = 'criminal-law' AND overview LIKE '%Bharatiya Nyaya Sanhita%';
    IF n <> 1 THEN
        RAISE EXCEPTION 'the criminal-law overview no longer names the Bharatiya Nyaya Sanhita, which replaced the IPC on 1 July 2024';
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
