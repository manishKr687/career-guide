-- Overviews for the Civil, Environmental, Mining and Petroleum Engineering
-- specializations. Third batch; V134 explains the rationale and the exclusions.
--
-- 22 rows: 8 under Civil Engineering, 5 under Environmental Engineering, 5 under
-- Mining Engineering, 4 under Petroleum Engineering.
--
-- INDIAN REGULATORY BODIES ARE NAMED WHERE THEY GOVERN THE WORK -- the DGMS for
-- mine safety, the CPCB and the national ambient standards for air, the IS codes
-- for structural design. These are institutional facts about how the discipline
-- is practised here, and they are what makes the difference between a generic
-- syllabus summary and one useful to a student in India. No numeric limit,
-- threshold or code clause is quoted: naming the regulator is checkable, quoting
-- its current values from memory is not, and they are revised.
--
-- WATER APPEARS UNDER THREE CAREERS and the overviews separate them: Civil
-- Engineering's Hydraulics is the mechanics of flow and the structures that
-- carry it, Water Resources is the catchment and its storage over time, and
-- Environmental Engineering's Water Treatment is the chemistry and biology of
-- making water fit to drink or to discharge.

UPDATE specializations SET overview = v.overview
FROM (VALUES

-- ------------------------------------------------------------ Civil Engineering

('construction-engineering',
 'This specialization covers delivering a structure once it has been designed: quantity estimation and rate analysis, tendering and contracts, project scheduling through bar charts, CPM and PERT, resource levelling, cost control, construction equipment and methods, site organisation, and quality assurance. Safety management on site is treated as part of the engineering rather than as paperwork, because most of what goes wrong on a project goes wrong here.'),

('geotechnical-engineering',
 'This specialization covers the ground a structure stands on: soil classification, permeability and seepage, effective stress, shear strength, compaction and consolidation, and then the design that follows from it -- shallow and deep foundations, pile capacity, retaining walls and earth pressure, and slope stability. Expect laboratory soil testing and field site investigation, since the parameters cannot be assumed.'),

('hydraulics',
 'This specialization covers water in motion and the structures built to control it: pressurised pipe flow and losses, open channel flow, specific energy and hydraulic jumps, flow measurement, pumps and turbines, sediment transport, and the design of weirs, spillways, canals and energy dissipators. Expect laboratory flume work alongside computational modelling of channel networks.'),

('structural-engineering',
 'This specialization covers making a structure carry its loads safely: analysis of determinate and indeterminate frames, influence lines, matrix and finite element methods, and design in reinforced concrete, steel and prestressed concrete to the relevant IS codes. Expect load estimation for dead, live, wind and seismic cases, ductile detailing for earthquake resistance, and the limit state philosophy that underlies current Indian practice.'),

('surveying-and-geomatics',
 'This specialization covers measuring and representing the earth''s surface: levelling, theodolite and total station traversing, tacheometry, curve setting out, and the modern layer above it -- GNSS positioning, photogrammetry and drone survey, remote sensing, and geographic information systems. Expect field practice and adjustment of observations, plus cadastral and alignment survey for construction projects.'),

('transportation-engineering',
 'This specialization covers moving people and goods: highway geometric design including sight distance, curves and superelevation, pavement materials and the design of flexible and rigid pavements, traffic studies, capacity and level of service, signal design, intersection layout, and the basics of railway track, airport and port engineering. Traffic flow theory and road safety analysis run through it.'),

('urban-infrastructure',
 'This specialization covers the networks a city runs on: water supply distribution and sewerage, storm water drainage, urban road hierarchy and street design, solid waste collection systems, and the coordination of utility corridors. Expect the planning frameworks that govern them -- master plans, development control rules and municipal service standards -- alongside the engineering, because in practice each constrains the other.'),

('water-resources',
 'This specialization covers where water comes from and how it is stored and shared: the hydrologic cycle, rainfall analysis and rainfall-runoff modelling, unit hydrographs, flood estimation and routing, groundwater flow and well hydraulics, reservoir planning and operation, dam types, and irrigation water requirement and canal systems. It is the catchment-scale view, over seasons rather than instants.'),

-- ---------------------------------------------------- Environmental Engineering

('air-pollution-control',
 'This specialization covers emissions to the atmosphere and their abatement: pollutant classes and their sources, meteorology and atmospheric dispersion modelling, stack design, and the control technologies -- cyclones, electrostatic precipitators, fabric filters, wet scrubbers, catalytic converters and adsorption beds. Expect ambient and source monitoring methods and the compliance framework administered by the CPCB and the state boards.'),

('environmental-monitoring',
 'This specialization covers producing environmental data that will stand up: sampling design and representativeness, collection and preservation of water, air, soil and noise samples, laboratory analysis and instrumentation, continuous online monitoring, calibration and quality control, and statistical treatment of the results. It also covers the reporting obligations the data feeds, since monitoring exists largely to satisfy them.'),

('sustainability',
 'This specialization covers assessing and reducing the environmental cost of an activity: life cycle assessment, carbon and water footprinting, energy and material efficiency, renewable substitution, circular economy and design for reuse, green building rating systems such as GRIHA and IGBC, and corporate environmental and ESG reporting. Quantification is the core skill, since the discipline exists to replace assertion with measurement.'),

('waste-management',
 'This specialization covers what happens to discarded material: waste characterisation and quantification, collection and segregation systems, composting and anaerobic digestion, material recovery and recycling, waste-to-energy, and engineered landfill design with liners, leachate collection and gas recovery. Hazardous, biomedical, electronic and construction waste are handled separately, each under its own set of Indian rules.'),

('water-treatment',
 'This specialization covers making water fit for a purpose: for supply, coagulation and flocculation, sedimentation, filtration, disinfection, softening and membrane processes; for wastewater, screening and primary settling, biological treatment through activated sludge, SBR, MBBR or MBR, secondary clarification, tertiary polishing and sludge handling. Expect unit process design and sizing against the discharge standards that apply.'),

-- ----------------------------------------------------------- Mining Engineering

('mine-planning',
 'This specialization covers deciding how a deposit will be extracted: orebody modelling and grade estimation, reserve classification, cut-off grade and pit or stope optimisation, mine layout and access design, long and short range production scheduling, equipment fleet selection and matching, capital and operating cost estimation, and closure and rehabilitation planning. Mine planning software is used throughout.'),

('mine-safety',
 'This specialization covers keeping people alive underground and on surface operations: mine ventilation design and airflow measurement, gas detection and firedamp control, spontaneous heating and mine fires, strata control and roof support, dust suppression and occupational health, blasting safety, illumination, and emergency preparedness and rescue. The regulatory framework is the DGMS regime, and statutory competency examinations sit alongside the coursework.'),

('mineral-processing',
 'This specialization covers concentrating a mineral after it leaves the mine: crushing and grinding circuits and the energy they consume, screening and classification, gravity separation, froth flotation and its reagent chemistry, magnetic and electrostatic separation, dewatering and filtration, and tailings handling and disposal. Expect mass balance and recovery-grade calculations as the central quantitative skill.'),

('mining-operations',
 'This specialization covers running the extraction itself: surface methods including opencast benching and strip mining, underground methods such as bord and pillar and longwall, drilling and blast design, loading and hauling systems, ground support, ventilation in practice, dewatering, equipment availability and maintenance, and productivity measurement. Much of the work is the daily coordination of a cycle under changing ground conditions.'),

('rock-mechanics',
 'This specialization covers how rock deforms and fails: laboratory determination of rock strength and deformability, in-situ stress and its measurement, failure criteria, discontinuities and joint behaviour, rock mass classification systems such as RMR and Q, and stability analysis of slopes, tunnels and underground openings. Expect numerical modelling and field instrumentation for convergence and load monitoring.'),

-- -------------------------------------------------------- Petroleum Engineering

('drilling',
 'This specialization covers boring the well: rig systems and components, drill string and bit selection, rock-bit interaction and rate of penetration, drilling fluid formulation and hydraulics, cuttings transport, hole problems such as stuck pipe and lost circulation, well control and blowout preventers, directional and horizontal drilling, and casing design and cementing. Well control is the part on which everything else depends.'),

('petroleum-geology',
 'This specialization covers where hydrocarbons are and why: sedimentary basin formation, source rock deposition and thermal maturation, migration, reservoir rock porosity and permeability, trap and seal geometry, and the methods used to find all of it -- seismic acquisition and interpretation, well logging and log analysis, core description and basin modelling. It is the exploration end of the discipline, and the interpretation is inherently uncertain.'),

('reservoir-engineering',
 'This specialization covers how much can be produced from a reservoir and how fast: rock and fluid properties and PVT behaviour, Darcy flow and relative permeability, material balance, natural drive mechanisms, decline curve analysis, pressure transient and well test interpretation, recovery factors, secondary recovery by water and gas injection, and enhanced recovery methods. Numerical reservoir simulation is the working tool.'),

('well-engineering',
 'This specialization covers designing the well as a permanent structure and keeping it sound: well architecture and casing scheme, load cases and tubular selection, cementing design, completion types, perforating, sand control, artificial lift by gas lift or pumping, stimulation through acidising and hydraulic fracturing, workover and intervention, and well integrity management through the producing life and abandonment.')

) AS v(slug, overview)
WHERE specializations.slug = v.slug;

DO $$
DECLARE n int; bad text;
BEGIN
    SELECT count(*) INTO n FROM specializations
    WHERE primary_career_slug IN ('civil-engineering', 'environmental-engineering',
                                  'mining-engineering', 'petroleum-engineering')
      AND overview IS NOT NULL AND overview <> '';
    IF n <> 22 THEN
        RAISE EXCEPTION 'expected 22 civil/earth specializations with an overview, found % -- a slug did not match', n;
    END IF;

    SELECT count(*), string_agg(slug, ', ' ORDER BY slug) INTO n, bad
    FROM specializations
    WHERE primary_career_slug IN ('civil-engineering', 'environmental-engineering',
                                  'mining-engineering', 'petroleum-engineering')
      AND (overview IS NULL OR overview = '');
    IF n > 0 THEN
        RAISE EXCEPTION '% civil/earth specialization(s) still have no overview: %', n, bad;
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
