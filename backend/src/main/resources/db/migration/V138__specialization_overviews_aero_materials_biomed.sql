-- Overviews for the Aerospace, Metallurgical & Materials and Biomedical
-- Engineering specializations. Fifth batch; V134 explains rationale and
-- exclusions.
--
-- 20 rows: 8 under Aerospace Engineering, 7 under Metallurgical & Materials
-- Engineering, 5 under Biomedical Engineering.
--
-- SATELLITE AND SPACECRAFT ENGINEERING ARE NOT CLEANLY SEPARABLE, and the two
-- overviews say so rather than manufacture a distinction. In practice the
-- difference is emphasis: Satellite Engineering is oriented to an earth-orbiting
-- spacecraft and the bus, payload and ground segment that make it useful, while
-- Spacecraft Engineering is the wider systems-engineering discipline covering
-- any vehicle operating outside the atmosphere. Different departments draw the
-- line in different places.
--
-- REGULATORY PATHWAYS ARE NAMED for the medical device specializations, since a
-- device engineer's work is defined by them -- the CDSCO in India, the FDA and
-- the CE marking route abroad, and ISO 14971 for risk management. As in V136, the
-- bodies and standards are named but no clause or threshold is quoted.

UPDATE specializations SET overview = v.overview
FROM (VALUES

-- -------------------------------------------------------- Aerospace Engineering

('aerodynamics',
 'This specialization covers the forces air exerts on a body moving through it: potential flow, airfoil and finite wing theory, lift and induced drag, boundary layers and separation, and compressible flow with shock waves and expansion at transonic and supersonic speeds. Expect wind tunnel testing and computational fluid dynamics, used together because each checks assumptions the other has to make.'),

('aerospace-structures',
 'This specialization covers airframe structures, where every kilogram is contested: thin-walled and semi-monocoque construction, shear flow in stiffened panels, torsion of closed sections, buckling and post-buckling of plates and columns, fatigue and damage tolerance, fibre composite laminates, and aeroelastic phenomena such as flutter. Finite element analysis and structural testing run alongside classical analysis.'),

('aircraft-design',
 'This specialization covers the synthesis step: turning a requirement into a configuration through weight estimation and iteration, wing and tail sizing, engine selection and integration, layout and centre of gravity control, performance and mission analysis, and stability and control sizing. It draws on aerodynamics, structures and propulsion at once, and airworthiness certification requirements shape the design from the first sketch.'),

('avionics',
 'This specialization covers the electronic systems an aircraft depends on: inertial and satellite navigation and their integration, air data systems, communication and radar, flight instruments and displays, autopilots and fly-by-wire control, and the data buses that connect them such as MIL-STD-1553 and the ARINC standards. Expect redundancy, fault tolerance and the software assurance regime that safety-critical airborne code is written under.'),

('flight-mechanics',
 'This specialization covers how an aircraft moves and whether it stays controllable: the equations of motion, performance analysis for takeoff, climb, cruise range and endurance, turning flight and manoeuvre envelopes, trim, static and dynamic stability, control surface effectiveness and stability derivatives, and the classical longitudinal and lateral modes. Flight test methods and data reduction complete it.'),

('propulsion',
 'This specialization covers producing thrust: the Brayton cycle and its variants, turbojet, turbofan and turboprop engines, axial and centrifugal compressors, turbines and their cooling, combustors and combustion stability, inlets and nozzles, and rocket propulsion with solid, liquid and hybrid propellants including nozzle theory and staging. Performance matching between components is the recurring analytical problem.'),

('satellite-engineering',
 'This specialization covers earth-orbiting spacecraft as working systems: orbital mechanics and orbit selection, attitude determination and control, power generation and storage, thermal control, telemetry, tracking and command, and the payload itself -- communications, remote sensing or navigation. Expect link budget calculation, launch and deployment sequencing, and the ground segment that operates the satellite once it is up.'),

('spacecraft-engineering',
 'This specialization covers vehicles designed to operate outside the atmosphere, treated as a systems-engineering problem: mission and trajectory design, structures and materials under launch loads and in vacuum, thermal control, chemical and electric propulsion, power, radiation environment and shielding, reliability and redundancy, and assembly, integration and test. It overlaps deliberately with Satellite Engineering, which narrows the same subject to earth orbit.'),

-- --------------------------------- Metallurgical & Materials Engineering

('ceramic-materials',
 'This specialization covers inorganic non-metallic materials and why they are strong but brittle: crystal and glass structure, powder synthesis and characterisation, forming and sintering, phase equilibria, and fracture behaviour and Weibull statistics. Expect the industrial families -- refractories, whitewares, cements and glasses -- alongside the functional ones used for their electrical, magnetic, optical or biomedical properties.'),

('corrosion-engineering',
 'This specialization covers metals degrading in their environment and how that is prevented: electrochemical thermodynamics and kinetics, Pourbaix and polarisation behaviour, and the distinct forms -- uniform attack, galvanic, pitting, crevice, intergranular, erosion and stress corrosion cracking. Expect rate measurement and monitoring, and the control methods: material selection, coatings and linings, inhibitors, and cathodic and anodic protection.'),

('materials-processing',
 'This specialization covers converting material into a component while controlling its structure: solidification and casting, bulk and sheet deformation processing and the accompanying recovery and recrystallisation, powder metallurgy and sintering, joining and welding metallurgy, heat treatment, surface engineering and coatings, and additive processes. The through-line is that processing sets the microstructure and the microstructure sets the properties.'),

('materials-science',
 'This specialization covers why materials have the properties they do: crystallography and crystal defects, dislocations, diffusion, phase diagrams and phase transformations, and the resulting mechanical, thermal, electrical, magnetic and optical behaviour across metals, ceramics, polymers and composites. Expect substantial characterisation work -- X-ray diffraction, optical and electron microscopy, thermal analysis and mechanical testing.'),

('metallurgy',
 'This specialization covers metals from ore to finished alloy: mineral beneficiation and extraction by pyrometallurgical, hydrometallurgical and electrometallurgical routes, iron and steelmaking including the blast furnace and secondary refining, and then physical metallurgy -- phase diagrams, TTT and CCT behaviour, heat treatment, and the structure and properties of ferrous and non-ferrous alloys. Mechanical working and failure analysis complete it.'),

('nanomaterials',
 'This specialization covers materials engineered at a scale where size itself changes behaviour: quantum confinement and the dominance of surface area, bottom-up and top-down synthesis routes, and the principal classes -- nanoparticles, nanowires, carbon nanotubes, graphene and other two-dimensional materials. Expect characterisation by electron microscopy, AFM and diffraction, and attention to dispersion, agglomeration and nanotoxicity.'),

('polymer-materials',
 'This specialization covers long-chain molecules and the solids made from them: polymerisation mechanisms, molecular weight and its distribution, crystallinity and the glass transition, viscoelasticity and rheology, and mechanical behaviour including creep and yielding. Expect the processing routes that define industrial practice -- extrusion, injection and blow moulding, casting and compounding -- plus fibre composites, degradation, stabilisation and recycling.'),

-- ------------------------------------------------------- Biomedical Engineering

('biomaterials',
 'This specialization covers materials intended to function inside the body: metallic, ceramic and polymeric implant materials and their mechanical matching to tissue, biocompatibility and the host inflammatory and immune response, corrosion and degradation in physiological conditions, wear and particulate debris, surface modification to control cell adhesion, and resorbable scaffolds for tissue engineering. Expect the in-vitro and in-vivo testing standards that precede clinical use.'),

('biomedical-instrumentation',
 'This specialization covers measuring the body electrically and physically: the origin of bioelectric signals and the recording of ECG, EEG and EMG, electrodes and their interface impedance, instrumentation amplifiers, isolation and noise rejection, filtering and artefact removal, and transducers for pressure, flow, temperature and blood gases. Patient electrical safety -- leakage current limits, isolation and earthing -- is central rather than incidental.'),

('medical-devices',
 'This specialization covers taking a device from concept to approved product: user and clinical needs, design controls and traceability, risk management under ISO 14971, biocompatibility and sterilisation validation, usability and human factors, verification and clinical evaluation, and the regulatory routes -- CDSCO licensing in India, FDA clearance or approval, and CE marking. Manufacturing under a quality management system and post-market surveillance complete the lifecycle.'),

('medical-imaging',
 'This specialization covers how the inside of the body is made visible: projection radiography and computed tomography, ultrasound and Doppler, magnetic resonance imaging and its pulse sequences, and nuclear medicine including PET and SPECT. Expect the reconstruction mathematics, image quality in terms of contrast, resolution, noise and artefacts, radiation dose and protection, and digital image processing, registration and increasingly machine learning on the output.'),

('rehabilitation-engineering',
 'This specialization covers restoring function that has been lost: prosthetic limbs and orthotic devices, socket and interface design, gait and motion analysis with force plates and motion capture, wheelchairs and seating and pressure management, assistive and access technology, functional electrical stimulation, and brain-computer interfaces. The design is done with the user rather than for them, so clinical collaboration and universal design principles are part of the method.')

) AS v(slug, overview)
WHERE specializations.slug = v.slug;

DO $$
DECLARE n int; bad text;
BEGIN
    SELECT count(*) INTO n FROM specializations
    WHERE primary_career_slug IN ('aerospace-engineering',
                                  'metallurgical-and-materials-engineering',
                                  'biomedical-engineering')
      AND overview IS NOT NULL AND overview <> '';
    IF n <> 20 THEN
        RAISE EXCEPTION 'expected 20 aero/materials/biomed specializations with an overview, found % -- a slug did not match', n;
    END IF;

    SELECT count(*), string_agg(slug, ', ' ORDER BY slug) INTO n, bad
    FROM specializations
    WHERE primary_career_slug IN ('aerospace-engineering',
                                  'metallurgical-and-materials-engineering',
                                  'biomedical-engineering')
      AND (overview IS NULL OR overview = '');
    IF n > 0 THEN
        RAISE EXCEPTION '% aero/materials/biomed specialization(s) still have no overview: %', n, bad;
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
