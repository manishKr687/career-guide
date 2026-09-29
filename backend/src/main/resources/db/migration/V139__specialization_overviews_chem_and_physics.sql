-- Overviews for the Chemical Engineering, Chemistry and Physics specializations.
-- Sixth batch; V134 explains rationale and exclusions.
--
-- 21 rows: 7 under Chemical Engineering, 7 under Chemistry, 7 under Physics.
--
-- TWO BOUNDARIES WORTH STATING, because both pairs sit under different careers
-- and a student will land on one page without seeing the other:
--   * Chemical Process Design is synthesis on paper -- a flowsheet that does not
--     exist yet. Process Engineering is the plant that does exist, its unit
--     operations and its problems. Departments teach them in that order.
--   * Medical Physics here is the clinical use of radiation and its safety;
--     Medical Imaging under Biomedical Engineering (V138) is the engineering of
--     the scanner and its reconstruction. Same machines, different question.
--
-- The AERB is named as the Indian regulator for medical radiation practice, on
-- the same basis as the DGMS and CPCB in V136: the body is a durable fact, its
-- current dose limits and licence conditions are not, and are not quoted.

UPDATE specializations SET overview = v.overview
FROM (VALUES

-- --------------------------------------------------------- Chemical Engineering

('biochemical-engineering',
 'This specialization covers running biological reactions at industrial scale: enzyme kinetics and immobilisation, microbial growth and substrate utilisation models, bioreactor configurations and their design, sterilisation, oxygen transfer and mixing, and the downstream recovery sequence of cell separation, disruption, precipitation, membrane filtration and chromatography. Scale-up and contamination control are the recurring practical constraints.'),

('chemical-process-design',
 'This specialization covers assembling a process that does not exist yet: flowsheet synthesis and route selection, mass and energy balances over the whole plant, equipment sizing and specification, heat integration and pinch analysis, utility systems, process simulation in a tool such as Aspen or DWSIM, and capital and operating cost estimation with profitability analysis. Safety review through HAZOP is part of the design rather than a later check.'),

('environmental-process-engineering',
 'This specialization covers the environmental load a chemical plant creates and how it is reduced: effluent characterisation and treatment, control of gaseous emissions and volatile organic compounds, solvent recovery, process and hazardous waste handling, water reuse and zero liquid discharge, and waste minimisation designed into the process rather than added at the end. Compliance with the applicable Indian discharge and emission norms frames the work.'),

('petroleum-and-petrochemicals',
 'This specialization covers refining crude oil and building chemicals from it: crude assay and distillation, the conversion processes -- catalytic and hydrocracking, catalytic reforming, coking, alkylation and isomerisation -- treating and blending, and then the petrochemical tree, from olefins and aromatics through to polymer and fibre intermediates. Catalysis and refinery economics run through the whole subject.'),

('polymer-engineering',
 'This specialization covers producing and shaping polymers at scale: polymerisation reactor design and reaction engineering, molecular weight control, rheology and melt flow behaviour, compounding with fillers, plasticisers and stabilisers, and the processing routes -- extrusion, injection and blow moulding, calendering and film forming. Product and mould design, characterisation and testing, and degradation and recycling complete it.'),

('process-control',
 'This specialization covers holding a plant at its intended operating point: process dynamics and transfer function modelling, first and second order response, feedback loops and PID tuning, cascade, ratio and feedforward schemes, dead time and stability, sensors and control valves, and multivariable and model predictive control. Expect the distributed control system as the working environment, plus alarm management and safety instrumented systems.'),

('process-engineering',
 'This specialization covers the operating plant and the unit operations inside it: fluid flow and pumping, heat exchange, evaporation, distillation, absorption, extraction, adsorption, drying and crystallisation, together with chemical reaction engineering and reactor behaviour. Expect the working skills of the role -- monitoring performance against design, troubleshooting a unit that has drifted, debottlenecking, and planning turnarounds.'),

-- ------------------------------------------------------------------- Chemistry

('analytical-chemistry',
 'This specialization covers determining what a sample contains and how much: sampling and sample preparation, classical gravimetric and volumetric methods, spectroscopic techniques including UV-visible, infrared, atomic absorption and emission, chromatographic separation by GC and HPLC, mass spectrometry and hyphenated methods, and electroanalytical techniques. Calibration, method validation, detection limits and the statistics of measurement error are treated as core.'),

('biochemistry',
 'This specialization covers the chemistry of living systems: the structure and function of proteins, nucleic acids, carbohydrates and lipids, enzyme mechanism and kinetics and their regulation, the central metabolic pathways and their control, bioenergetics and membrane transport, and molecular genetics from replication through transcription to translation. Expect laboratory technique -- electrophoresis, chromatography, spectrophotometric assay and PCR.'),

('industrial-chemistry',
 'This specialization covers chemistry as it is practised in manufacturing: unit processes and their reaction engineering, industrial catalysis, and the major product routes -- heavy inorganics such as acids, alkalis and fertilisers, along with dyes, surfactants, agrochemicals, pharmaceuticals intermediates and petrochemicals. Expect scale-up from bench to plant, quality control and specification, and process safety and hazardous material handling.'),

('inorganic-chemistry',
 'This specialization covers the elements other than carbon and the compounds they form: periodicity and bonding models, acid-base and redox behaviour, coordination compounds with crystal field and ligand field theory, spectra and magnetic properties, organometallic chemistry and homogeneous catalysis, main group and solid state chemistry, and bioinorganic systems such as metalloenzymes. Synthesis under inert conditions is the characteristic laboratory skill.'),

('materials-chemistry',
 'This specialization covers making materials with intended properties through chemistry: solid state structure and defects, and synthesis routes including solid state reaction, sol-gel, hydrothermal, chemical vapour deposition and self-assembly. Expect nanomaterials, polymers and hybrid and composite systems, functional electronic, magnetic and optical materials, energy materials for batteries, photovoltaics and catalysis, and characterisation by diffraction, microscopy and thermal analysis.'),

('organic-chemistry',
 'This specialization covers the chemistry of carbon compounds and how they are made: structure, bonding and stereochemistry, reaction mechanisms and reactive intermediates, functional group transformations, the named reactions and their scope, pericyclic and photochemical reactions, heterocyclic chemistry, and retrosynthetic planning of a multi-step synthesis. Structure determination by NMR, IR and mass spectrometry is inseparable from it, as is bench synthesis and purification.'),

('physical-chemistry',
 'This specialization covers the physical principles underlying chemical behaviour: the laws of thermodynamics applied to chemical and phase equilibria, solutions and colligative properties, reaction kinetics and mechanism, catalysis, electrochemistry and ion transport, quantum chemistry from the Schrodinger equation to molecular orbitals, molecular spectroscopy, statistical thermodynamics, and surface and colloid chemistry.'),

-- --------------------------------------------------------------------- Physics

('applied-physics',
 'This specialization covers physics directed at building and measuring things rather than at fundamental questions: applied mechanics, electromagnetism and thermal physics, solid state and semiconductor behaviour, optics, lasers and photonics, vacuum and thin film technique, electronics and instrumentation, and materials characterisation. Expect experimental design, error analysis and sensor and measurement system work to be the central competence.'),

('astrophysics',
 'This specialization covers the physics of stars, galaxies and the universe: radiative transfer and stellar spectra, stellar structure, energy generation and evolution, the end states -- white dwarfs, neutron stars and black holes -- the interstellar medium, galactic structure and dynamics, and cosmology from the expanding universe to the microwave background. Expect observational technique across the wavebands and substantial data analysis, since the subject is inferential.'),

('condensed-matter-physics',
 'This specialization covers the collective behaviour of matter in bulk: crystal structure and the reciprocal lattice, diffraction, lattice vibrations and phonons, free electron and band theory, semiconductors, dielectric and optical response, magnetism and magnetic ordering, superconductivity, and low-dimensional and disordered systems. Expect low-temperature and high-field experimental methods alongside the theory.'),

('medical-physics',
 'This specialization covers the clinical use of radiation and the physics that makes it safe: radiation interaction with tissue, dosimetry and its instrumentation, radiotherapy with external beams and brachytherapy including treatment planning and verification, the physics of diagnostic imaging, nuclear medicine, radiobiology, quality assurance of clinical equipment, and radiation protection and shielding. Practice in India is regulated by the AERB, and the role is a clinical one.'),

('nuclear-physics',
 'This specialization covers the nucleus and its transformations: nuclear size, binding energy and the shell and collective models, radioactive decay modes and decay chains, nuclear reactions and cross sections, fission and fusion, and the interaction of radiation with matter. Expect detector physics and spectroscopy, accelerators, neutron physics, and an introduction to reactor physics and to applications in energy, medicine and dating.'),

('quantum-physics',
 'This specialization covers the formalism that describes matter at atomic scale and how it is used: the postulates and state vectors, the Schrodinger equation and its exactly solvable cases, operators and observables, angular momentum and spin, approximation by perturbation and variational methods, identical particles and exchange, scattering, entanglement and measurement, and the foundations of quantum computing and information.'),

('theoretical-physics',
 'This specialization covers the mathematical structure of physical theory: Lagrangian and Hamiltonian mechanics and symmetry and conservation laws, classical electrodynamics and special relativity, statistical mechanics and phase transitions, advanced quantum mechanics leading into quantum field theory, and general relativity. Mathematical methods -- complex analysis, group theory, differential geometry and tensors -- are studied as tools of the trade.')

) AS v(slug, overview)
WHERE specializations.slug = v.slug;

DO $$
DECLARE n int; bad text;
BEGIN
    SELECT count(*) INTO n FROM specializations
    WHERE primary_career_slug IN ('chemical-engineering', 'chemistry', 'physics')
      AND overview IS NOT NULL AND overview <> '';
    IF n <> 21 THEN
        RAISE EXCEPTION 'expected 21 chemistry/physics specializations with an overview, found % -- a slug did not match', n;
    END IF;

    SELECT count(*), string_agg(slug, ', ' ORDER BY slug) INTO n, bad
    FROM specializations
    WHERE primary_career_slug IN ('chemical-engineering', 'chemistry', 'physics')
      AND (overview IS NULL OR overview = '');
    IF n > 0 THEN
        RAISE EXCEPTION '% chemistry/physics specialization(s) still have no overview: %', n, bad;
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
