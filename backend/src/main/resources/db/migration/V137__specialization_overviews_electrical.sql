-- Overviews for the Electrical and Electronics & Communication Engineering
-- specializations. Fourth batch; V134 explains the rationale and the exclusions.
--
-- 17 rows: 8 under Electrical Engineering, 9 under Electronics & Communication
-- Engineering.
--
-- TWO PAIRS HERE ARE GENUINELY CLOSE and the overviews say so instead of
-- inventing a clean line:
--   * RF Engineering and Microwave Engineering are the same physics approached
--     from two ends -- lumped circuit design at radio frequencies versus guided
--     waves, distributed elements and components as frequency rises. The split is
--     by frequency and by treatment, not by subject, and they overlap.
--   * Electronics Design and VLSI differ by scale: a board built from purchased
--     parts, against the transistors and layout inside one chip.
-- Naming the overlap is more useful to a student than a tidy distinction that
-- their syllabus will then contradict.

UPDATE specializations SET overview = v.overview
FROM (VALUES

-- ------------------------------------------------------- Electrical Engineering

('control-systems',
 'This specialization covers making a system behave as intended through feedback: modelling in transfer function and state space form, time and frequency response, root locus, Bode and Nyquist analysis, stability criteria, and the design of PID, lead-lag and state feedback controllers. Expect discrete-time and digital control, observers and controllability, and laboratory work on real plants where the model is only approximate.'),

('electrical-design',
 'This specialization covers designing an electrical installation that is safe and will pass inspection: load estimation and diversity, cable sizing and voltage drop, transformer and switchgear selection, short circuit calculation, protection device selection and discrimination, earthing and lightning protection, illumination design, and panel and substation layout. Work is governed throughout by the IS and IEC standards and by statutory wiring rules.'),

('electrical-machines',
 'This specialization covers the machines that convert between electrical and mechanical energy: DC machines, single and three phase transformers, induction motors, and synchronous machines and generators. Expect equivalent circuit modelling, performance prediction, standard tests, starting and speed control methods, and the more recent members of the family such as brushless DC and switched reluctance machines.'),

('high-voltage-engineering',
 'This specialization covers the behaviour of insulation when the voltage is high enough to destroy it: breakdown mechanisms in gases, liquids and solid dielectrics, partial discharge and corona, lightning and switching surges, insulation coordination and surge arresters, and the generation and measurement of high AC, DC and impulse voltages. Expect non-destructive testing of equipment insulation as a substantial practical component.'),

('power-electronics',
 'This specialization covers switching electrical power efficiently: the device families from diodes and thyristors through MOSFETs and IGBTs to wide-bandgap devices, and the converters built from them -- controlled rectifiers, choppers, single and three phase inverters, and resonant and switched-mode supplies. Expect pulse width modulation and control, magnetic component and thermal design, and application to motor drives and grid-tied converters.'),

('power-systems',
 'This specialization covers the generation, transmission and distribution network as one interconnected system: per-unit modelling, transmission line parameters, load flow analysis, symmetrical components and fault calculation, protective relaying and coordination, transient and steady-state stability, reactive power and voltage control, economic load dispatch, and HVDC and FACTS devices.'),

('renewable-energy',
 'This specialization covers generating electricity from non-depleting sources and getting it into the grid: solar photovoltaic cell physics, module and array design, maximum power point tracking and inverters; wind resource assessment, turbine aerodynamics and generator topologies; plus small hydro, biomass and geothermal. Expect resource and site assessment, storage sizing, hybrid system design, and the grid connection and metering rules that apply in India.'),

('smart-grid',
 'This specialization covers instrumenting and controlling the grid with communications and data: SCADA and substation automation, phasor measurement units and wide-area monitoring, advanced metering infrastructure, distribution automation and self-healing networks, demand response, integration of distributed generation and electric vehicles, and microgrid operation. Communication protocols and grid cybersecurity are part of the subject rather than adjacent to it.'),

-- ---------------------------------- Electronics & Communication Engineering

('communication-systems',
 'This specialization covers carrying information over an imperfect channel: analog and digital modulation, sampling and quantisation, baseband and passband transmission, noise and its effect on error rate, information theory and channel capacity, error control coding, equalisation, and multiple access methods. Expect the successive generations of cellular and wireless standards treated as applications of the same underlying theory.'),

('electronics-design',
 'This specialization covers designing working circuits and boards: analog design with amplifiers, operational amplifiers, filters and oscillators, digital logic and interfacing, power supply and regulator design, component selection and derating, schematic capture and multilayer PCB layout, signal integrity and EMI/EMC, and SPICE simulation followed by bring-up and debugging of the physical board. VLSI is the same discipline one level down, inside the chip.'),

('embedded-systems',
 'This specialization covers programming small computers built into products: microcontroller architecture and memory, bare-metal C and register-level programming, on-chip peripherals -- timers, ADC, PWM, UART, SPI, I2C -- interrupt handling, real-time operating systems and scheduling, bootloaders and firmware update, low-power design, and debugging with a JTAG probe and a logic analyser rather than a print statement.'),

('microwave-engineering',
 'This specialization covers electromagnetic energy at frequencies where circuits behave as distributed structures: transmission line theory and the Smith chart, waveguides and cavity resonators, scattering parameters, microstrip and passive components such as couplers, filters and circulators, microwave tubes and solid-state sources, antennas and propagation, and radar. RF Engineering approaches the same physics from the circuit side.'),

('optical-communication',
 'This specialization covers sending information as light through fibre: optical propagation in step and graded index fibre, attenuation and dispersion mechanisms, sources including LEDs and laser diodes, photodetectors and receiver noise, optical amplifiers such as the EDFA, wavelength division multiplexing, and passive components. Expect optical link power and dispersion budgets, and the architecture of passive optical access and long-haul transport networks.'),

('rf-engineering',
 'This specialization covers circuit design at radio frequencies, where layout and parasitics become part of the circuit: impedance matching networks, low noise amplifiers, power amplifiers and linearity, mixers, oscillators and phase-locked loops, RF filters, noise figure and sensitivity, transceiver architecture, link budget, and antenna interfacing. Measurement with a vector network and spectrum analyser is central. Microwave Engineering continues the same subject into guided-wave territory.'),

('semiconductor-technology',
 'This specialization covers how semiconductor devices work and how they are manufactured: carrier transport and junction physics, MOS capacitor and MOSFET operation, short-channel effects, and then the fabrication sequence -- crystal growth, oxidation, photolithography, doping by diffusion and implantation, thin film deposition and etching. Expect device characterisation, packaging, and yield and process control, which is where most of the economics sits.'),

('signal-processing',
 'This specialization covers extracting information from sampled signals: sampling and aliasing, the z-transform, discrete Fourier transform and FFT, FIR and IIR filter design and their trade-offs, multirate processing, spectral estimation, random signals and correlation, and adaptive filtering. Expect implementation as well as theory -- fixed-point arithmetic, quantisation effects, and real-time execution on a DSP or FPGA.'),

('vlsi',
 'This specialization covers designing integrated circuits: CMOS device and inverter behaviour, combinational and sequential logic families, layout and design rules, delay, power and noise, and the digital design flow -- RTL description in Verilog or VHDL, synthesis, floorplanning, place and route, static timing analysis, design for testability and low-power techniques. Analog and mixed-signal layout and the tape-out checks form the remainder.')

) AS v(slug, overview)
WHERE specializations.slug = v.slug;

DO $$
DECLARE n int; bad text;
BEGIN
    SELECT count(*) INTO n FROM specializations
    WHERE primary_career_slug IN ('electrical-engineering',
                                  'electronics-and-communication-engineering')
      AND overview IS NOT NULL AND overview <> '';
    IF n <> 17 THEN
        RAISE EXCEPTION 'expected 17 electrical/electronics specializations with an overview, found % -- a slug did not match', n;
    END IF;

    SELECT count(*), string_agg(slug, ', ' ORDER BY slug) INTO n, bad
    FROM specializations
    WHERE primary_career_slug IN ('electrical-engineering',
                                  'electronics-and-communication-engineering')
      AND (overview IS NULL OR overview = '');
    IF n > 0 THEN
        RAISE EXCEPTION '% electrical/electronics specialization(s) still have no overview: %', n, bad;
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
