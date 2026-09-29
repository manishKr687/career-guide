-- Overviews for the Mechanical, Industrial and Manufacturing Engineering
-- specializations. Second batch; V134 explains why these are being written and
-- what they deliberately leave out.
--
-- 22 rows: 10 under Mechanical Engineering, 7 under Industrial Engineering, 5
-- under Manufacturing Engineering.
--
-- THESE THREE CAREERS OVERLAP MORE THAN THE COMPUTING PAIR DID, and pretending
-- otherwise would make a dozen of these pages read alike. The distinction the
-- overviews hold to:
--   * Mechanical Engineering designs the machine and the process physics.
--   * Manufacturing Engineering is the process and its equipment in depth --
--     how the part is actually cut, printed or assembled.
--   * Industrial Engineering treats the whole system as the object of study:
--     flow, capacity, quality and cost, largely independent of what is made.
-- So Mechanical's "Manufacturing" is a survey of processes, Manufacturing
-- Engineering's "CNC & Machining" is one of them in depth, and Industrial
-- Engineering's "Production Planning" is about scheduling the shop that runs
-- them. Where two pages sit close together the overview says which is which,
-- because a student choosing between them is asking precisely that.

UPDATE specializations SET overview = v.overview
FROM (VALUES

-- ------------------------------------------------------- Mechanical Engineering

('automotive-engineering',
 'This specialization covers the engineering of road vehicles: internal combustion engines and electric powertrains, transmissions and drivelines, vehicle dynamics, suspension, steering and braking, chassis and body structure, and noise, vibration and harshness. Expect work on crash safety and on the emissions and homologation standards a vehicle has to meet before it can be sold, which constrain the design as tightly as the physics does.'),

('cad-cam',
 'This specialization covers the software chain from a drawing to a finished part: parametric solid and surface modelling, assemblies, engineering drawings with geometric dimensioning and tolerancing, and then the manufacturing side -- toolpath generation, simulation of the cut, and post-processing into the G-code a machine will run. Expect substantial hands-on time in a tool such as SolidWorks, CATIA, NX or Fusion.'),

('energy-engineering',
 'This specialization covers how energy is converted and delivered: thermodynamic cycles, steam, gas and combined-cycle power plants, boilers, turbines and heat exchangers, and the renewable sources -- solar thermal and photovoltaic, wind, biomass and hydro. Expect energy auditing and conservation methods, cogeneration, storage, and the efficiency and emissions accounting used to compare one option against another.'),

('fluid-engineering',
 'This specialization covers the behaviour of liquids and gases in motion and the machines that move them: continuity, momentum and energy principles, laminar and turbulent flow, boundary layers, losses in pipe networks, and the design and performance of pumps, compressors, fans and turbines. Expect computational fluid dynamics alongside laboratory work, and dimensional analysis used to scale results from a model to the real thing.'),

('manufacturing',
 'This specialization is a survey of how parts are actually made: casting, forming and forging, sheet metal work, welding and joining, machining, powder metallurgy and polymer processing, together with metrology, jigs and fixtures and process planning. It is the breadth-first view from inside Mechanical Engineering; Manufacturing Engineering exists as a separate career for students who want any one of these processes and its equipment in depth.'),

('mechanical-design',
 'This specialization covers designing machine components so that they carry their loads and fit together: stress and strain analysis, failure theories, fatigue, and the design of shafts, gears, bearings, springs, fasteners and joints. Expect materials selection, tolerancing and fits, and finite element analysis used as a check on hand calculations rather than as a substitute for understanding them.'),

('mechatronics',
 'This specialization covers machines whose behaviour comes from mechanics, electronics and software acting together: sensors and actuators, signal conditioning, microcontrollers, hydraulics and pneumatics, feedback control, and programmable logic controllers. The discipline is integration -- building a working system from the three -- rather than depth in any one, and the coursework is correspondingly hands-on.'),

('production-engineering',
 'This specialization covers turning a design into volume output: process and tooling selection, jigs and fixtures, plant layout and material handling, work and time study, production control, and in-line quality assurance. It sits between Mechanical Engineering''s process knowledge and Industrial Engineering''s systems view, and is concerned with the shop floor as it actually runs.'),

('robotics-and-automation',
 'This specialization covers programmable machines that sense and act: forward and inverse kinematics, dynamics, trajectory planning, actuators and drives, sensors and machine vision, and feedback control. Expect programming of industrial arms and mobile robots, commonly through ROS, and the safety standards that govern a machine working near people. Manufacturing Automation under Manufacturing Engineering is the narrower, factory-floor counterpart.'),

('thermal-engineering',
 'This specialization covers heat and its conversion into work: thermodynamics, conduction, convection and radiation, heat exchanger design, internal combustion engines, steam generation, and refrigeration and air conditioning. Expect cycle analysis to be the core skill -- calculating what a given arrangement can deliver and where its losses are -- supported by laboratory measurement and simulation.'),

-- ------------------------------------------------------- Industrial Engineering

('lean-manufacturing',
 'This specialization covers eliminating work that adds no value, in the tradition of the Toyota Production System: value stream mapping, the categories of waste, pull scheduling through kanban and just-in-time, single-piece flow, setup reduction, 5S workplace organisation, total productive maintenance and continuous improvement through kaizen. It is a method for changing how a plant operates, and much of the difficulty is organisational rather than technical.'),

('operations-research',
 'This specialization covers making decisions by building a mathematical model of them: linear and integer programming and duality, network and transportation problems, dynamic programming, queuing theory, inventory models, and discrete-event simulation for systems too messy to solve in closed form. Expect a solid grounding in linear algebra and probability, and practical work with a solver or a discrete-event simulation tool.'),

('process-optimization',
 'This specialization covers finding and removing the constraint that limits a process: bottleneck and throughput analysis, cycle time and capacity study, design of experiments to identify which variables actually matter, simulation of proposed changes before they are made, and statistical process control to confirm the improvement held. Data analysis is the working method throughout.'),

('production-planning',
 'This specialization covers deciding what a plant will make and when: demand forecasting, aggregate and master production scheduling, material requirements planning and bills of materials, capacity and load balancing, shop-floor sequencing and dispatching, inventory policy including reorder points and economic order quantity, and how all of this is represented in an ERP system.'),

('quality-engineering',
 'This specialization covers establishing whether a process produces conforming output and why it sometimes does not: statistical process control and control charts, process capability indices, acceptance sampling, measurement system analysis, failure mode and effects analysis, root cause analysis, and the quality management standards -- ISO 9001 and sector equivalents -- together with the auditing they require.'),

('six-sigma',
 'This specialization covers a defined improvement methodology built on statistics: the DMAIC cycle, defining the problem and its cost, validating the measurement system, hypothesis testing and regression to find real causes, design of experiments, and control plans to hold the gain. It is usually studied alongside the Green Belt and Black Belt certifications, and overlaps deliberately with Lean Manufacturing and Quality Engineering.'),

('supply-chain',
 'This specialization covers the movement of goods from supplier to customer: sourcing and procurement, supplier selection and contracts, inventory across multiple locations, warehousing and materials handling, transportation and freight modes, distribution network design, and sales and operations planning. Expect demand variability and the bullwhip effect to be treated as central problems, along with cost-to-serve and resilience.'),

-- ---------------------------------------------------- Manufacturing Engineering

('additive-manufacturing',
 'This specialization covers building parts by adding material rather than removing it: the main process families -- material extrusion, vat photopolymerisation, powder bed fusion in polymer and metal, and binder jetting -- with their materials and limits. Expect build preparation, part orientation and support strategy, post-processing and heat treatment, dimensional and mechanical qualification, and design for additive manufacturing, which differs substantially from design for machining.'),

('advanced-manufacturing',
 'This specialization covers processes beyond conventional cutting and forming: electrical discharge, laser, electron beam, waterjet and ultrasonic machining, precision and micro-machining, composite and advanced-material processing, and surface engineering. Expect the Industry 4.0 layer as well -- in-process sensing, machine data collection and digital twins -- and the metrology needed to verify tolerances at these scales.'),

('cnc-and-machining',
 'This specialization covers computer-controlled material removal in depth: turning, milling, drilling and grinding, machine tool construction and axes, cutting tool geometry and materials, and the selection of speed, feed and depth of cut for a given material. Expect manual G and M code programming as well as CAM output, workholding and fixture design, tool wear and coolant, and inspection against drawing tolerances.'),

('manufacturing-automation',
 'This specialization covers automating a production line: programmable logic controllers and their programming, SCADA and HMI systems, industrial sensors and actuators, pneumatics, conveyors and material handling, industrial robots in pick-and-place, welding and palletising roles, machine vision for inspection, and integration upward into an MES. Machine safety -- interlocks, guarding and risk assessment -- is part of the design rather than an afterthought.'),

('production-systems',
 'This specialization covers how a factory is laid out and how work flows through it: job shop, batch, cellular and continuous flow arrangements, line balancing and takt time, the relationship between throughput, work in process and cycle time, buffer placement, changeover, and maintenance strategy. The object of study is the system rather than any single machine, and the analysis is quantitative.')

) AS v(slug, overview)
WHERE specializations.slug = v.slug;

DO $$
DECLARE n int; bad text;
BEGIN
    SELECT count(*) INTO n FROM specializations
    WHERE primary_career_slug IN ('mechanical-engineering', 'industrial-engineering',
                                  'manufacturing-engineering')
      AND overview IS NOT NULL AND overview <> '';
    IF n <> 22 THEN
        RAISE EXCEPTION 'expected 22 mechanical-family specializations with an overview, found % -- a slug did not match', n;
    END IF;

    SELECT count(*), string_agg(slug, ', ' ORDER BY slug) INTO n, bad
    FROM specializations
    WHERE primary_career_slug IN ('mechanical-engineering', 'industrial-engineering',
                                  'manufacturing-engineering')
      AND (overview IS NULL OR overview = '');
    IF n > 0 THEN
        RAISE EXCEPTION '% mechanical-family specialization(s) still have no overview: %', n, bad;
    END IF;

    -- The three table-wide invariants from V134, re-asserted so they hold after
    -- this batch too rather than only at the moment they were introduced.
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
