-- Overviews for the Design, Hospitality Management, Tourism and Sports Science
-- specializations. Final batch; V134 explains rationale and exclusions.
--
-- 22 rows: 8 under Design, 5 under Hospitality Management, 4 under Tourism, 5
-- under Sports Science. With these, every specialization in the catalogue has an
-- overview, and the closing assertion in this file checks exactly that.
--
-- THREE CROSS-CAREER PAIRS ARE RESOLVED HERE, completing the set begun in V134:
--   * Game Design (this file) is mechanics, levels and player experience. Game
--     Development under Computer Science & Engineering is the implementation.
--   * Interior Design (this file) is furnishing, finishes and the visual scheme.
--     Interior Architecture under Architecture (V145) is permanent spatial and
--     structural intervention within architectural practice.
--   * Industrial Design and Product Design sit under the same career and are the
--     hardest pair in the catalogue to separate honestly, because institutions
--     genuinely disagree. The overviews state the conventional emphasis --
--     industrial design toward form, ergonomics and manufacture of physical
--     goods, product design toward the user''s problem and a process that now
--     spans digital products -- and say that the boundary varies by programme,
--     rather than asserting a line a student''s prospectus will contradict.
--
-- REGULATORS AND GOVERNING BODIES ARE NAMED as elsewhere in this series: the
-- FSSAI and HACCP for food safety, IATA for travel, WADA and NADA for
-- anti-doping. Named only -- no limit, code clause or prohibited-substance
-- listing is reproduced, and the sports nutrition and sports medicine overviews
-- give no dietary, dosing or clinical advice.

UPDATE specializations SET overview = v.overview
FROM (VALUES

-- ---------------------------------------------------------------------- Design

('animation',
 'This specialization covers making images move convincingly: the principles of animation from timing and spacing to squash, stretch and anticipation, life drawing and gesture, storyboarding and animatics, character design, and both 2D frame-based work and the 3D pipeline of modelling, texturing, rigging, lighting and rendering. Expect motion capture, compositing and editing, and production in a tool chain such as Blender, Maya, Toon Boom and After Effects.'),

('fashion-design',
 'This specialization covers designing and making garments: fashion illustration and the croquis, textile and fibre knowledge and fabric behaviour, pattern making and grading, draping on the stand, garment construction and finishing, surface development through print, dyeing and embroidery, and the development of a coherent collection. Expect trend research and forecasting, CAD for fashion, costing, and an understanding of production and the Indian craft and textile context.'),

('game-design',
 'This specialization covers what makes a game worth playing: core mechanics and systems design, rules and the interaction of systems, level and encounter design, pacing, difficulty curves and progression, player motivation and reward structures, economy and balance, narrative and world building, and documentation that a team can build from. Paper prototyping and iterative playtesting are the working method. Game Development under Computer Science & Engineering implements what this discipline specifies.'),

('graphic-design',
 'This specialization covers communicating visually in two dimensions: typography and typographic hierarchy, colour theory, composition and grid systems, logo design and visual identity systems, layout for print and screen, illustration and image making, packaging, editorial and information design. Expect print production and prepress knowledge, fluency in a toolset such as Illustrator, Photoshop and InDesign, and the practice of working to a brief.'),

('industrial-design',
 'This specialization covers the design of manufactured physical products: form development and aesthetics, sketching and rendering, ergonomics and anthropometry, materials and their manufacturing processes, mechanism and assembly, model making and prototyping, surface finish and detail, and design for manufacture and cost. Its emphasis is on the object and how it is made; Product Design under the same career emphasises process and user problem, and programmes divide them differently.'),

('interior-design',
 'This specialization covers the look, feel and use of an interior: reading a client brief and budget, space planning and furniture layout, colour and material palettes, finishes, soft furnishing and textiles, decorative and mood lighting, joinery and fitting detail, styling and accessorising, and presentation through mood boards and visualisation. Interior Architecture under the Architecture career addresses permanent structural and spatial alteration instead.'),

('product-design',
 'This specialization covers designing a product around the problem it solves: user research and need finding, insight and opportunity framing, concept generation and the design thinking cycle, rapid prototyping and iterative user testing, resolving form with function, materials and production, usability and accessibility, and sustainability and lifecycle thinking. In current practice it spans physical and digital products, which is what most distinguishes it from Industrial Design.'),

('ui-ux-design',
 'This specialization covers designing digital products people can actually use: user research and interviews, personas and journey mapping, information architecture, task and interaction flows, wireframing and interactive prototyping, visual interface design and reusable design systems, typography and layout on screen, accessibility standards, usability testing and iteration, and handoff and collaboration with engineers. Figma or a comparable tool is the working environment.'),

-- ------------------------------------------------------- Hospitality Management

('event-management',
 'This specialization covers delivering events of any scale: concept development and feasibility, budgeting and revenue models, venue selection and layout, vendor sourcing and coordination, permissions, licences and insurance, food and beverage planning, stage, sound, lighting and audiovisual production, marketing, registration and ticketing, run sheets and on-site execution, crowd management and risk planning, and post-event evaluation and settlement.'),

('food-and-beverage',
 'This specialization covers the service and commercial operation of restaurants, bars and banquets: service styles and sequence, restaurant and banquet operations, menu knowledge, planning and engineering, food production fundamentals, beverage and bar service, guest handling and complaint recovery, and cost control through portioning, yield and pour cost. Hygiene and food safety under FSSAI requirements and HACCP discipline govern the practice.'),

('front-office',
 'This specialization covers the guest-facing core of a hotel: reservations and channel management, arrival, registration and the additional formalities required for foreign guests, room assignment and status control, key and security procedure, concierge and bell desk, guest relations and complaint handling, night audit, billing, cashiering and settlement, and upselling. Work is through a property management system, and occupancy, average rate and RevPAR are the measures of it.'),

('hotel-management',
 'This specialization covers a hotel as an integrated business rather than any one department: rooms division, food and beverage, housekeeping, engineering and maintenance, sales, marketing and revenue management, and the interdependence between them. Expect hotel classification and brand standards, departmental budgeting and profit and loss responsibility, manpower planning and rostering, quality and guest satisfaction measurement, and the licensing and statutory compliance a property operates under.'),

('housekeeping',
 'This specialization covers the condition of the property: guest room and public area cleaning procedures and standards, the cleaning agents, equipment and mechanised methods used, linen and uniform control, laundry operations, pest control, room inspection and discrepancy reporting, par stock calculation and inventory, staffing, scheduling and area allocation, liaison with maintenance, and safety in the handling of chemicals and equipment.'),

-- --------------------------------------------------------------------- Tourism

('destination-management',
 'This specialization covers a destination as a product to be developed and safeguarded: resource inventory and attraction assessment, carrying capacity and visitor management, coordination among the many stakeholders a destination has, destination marketing and branding, product and itinerary development, interpretation and signage, community-based and sustainable tourism, seasonality management, and assessment of economic, social and environmental impact.'),

('tourism-operations',
 'This specialization covers running tours and the ground arrangements behind them: tour planning, itinerary design and costing, contracting accommodation, transport and activity suppliers, ground handling and transfers, guiding, escorting and interpretation, documentation and permits including protected and restricted area requirements, handling groups against individual travellers, reservations, customer service and complaint resolution, and traveller safety and emergency procedure.'),

('travel-management',
 'This specialization covers the travel trade and corporate travel: airline geography, fare construction and ticketing, reservations through a global distribution system, passport, visa and travel documentation, travel insurance, rail, cruise and car hire products, corporate travel policy, expense control and supplier negotiation, and MICE business. The IATA framework and agency accreditation and settlement procedures define much of how the industry operates.'),

('travel-technology',
 'This specialization covers the systems the travel industry runs on: global distribution and central reservation systems, internet booking engines and online travel agencies, channel managers and inventory distribution, API and switch integration between suppliers and sellers, property and revenue management systems, payment gateways and fraud control, dynamic packaging, and the use of customer data for personalisation and recommendation.'),

-- -------------------------------------------------------------- Sports Science

('exercise-science',
 'This specialization covers the body''s response and adaptation to physical work: functional anatomy, exercise physiology across the cardiorespiratory, metabolic and neuromuscular systems, energy systems and substrate use, biomechanics of movement, training principles including overload, specificity, progression and periodisation, strength and conditioning programme design, and fitness assessment through field and laboratory testing. Adaptation in different populations and environments completes it.'),

('performance-analysis',
 'This specialization covers measuring what happens in training and competition and reporting it usefully: notational and event analysis, video capture, tagging and clipping, technical and tactical analysis, GPS and inertial sensor tracking for movement and workload, key performance indicator definition, reliability of coded data, statistical analysis and visualisation, and feeding findings back to coaches and athletes in a form and timeframe they can use.'),

('sports-medicine',
 'This specialization covers the athlete''s health and injury: pre-participation screening, injury mechanisms and prevention strategy, immediate management of acute injury, the common injuries by joint and by sport, diagnosis and the role of imaging, staged rehabilitation and objective return-to-play decisions, concussion recognition and graded return protocols, overtraining and relative energy deficiency, the female athlete, and the anti-doping framework administered by WADA and NADA.'),

('sports-nutrition',
 'This specialization covers feeding training and competition: energy requirement estimation and energy availability, carbohydrate, protein and fat periodisation around the training load, recovery nutrition, hydration and electrolyte balance, body composition assessment and its limits, weight-category and weight-making practice and its risks, competition and travel nutrition planning, and appraisal of supplement evidence together with the contamination risk that anti-doping rules place on the athlete.'),

('sports-psychology',
 'This specialization covers the mental side of performance: motivation and goal setting, arousal, anxiety and their relationship to performing, attention and concentration under pressure, imagery, self-talk and routines, confidence and self-efficacy, coping and resilience, team cohesion, group dynamics and leadership, the psychological course of injury and rehabilitation, burnout and dropout, and the delivery of mental skills training to individuals and squads.')

) AS v(slug, overview)
WHERE specializations.slug = v.slug;

DO $$
DECLARE n int; bad text;
BEGIN
    SELECT count(*) INTO n FROM specializations
    WHERE primary_career_slug IN ('design', 'hospitality-management', 'tourism',
                                  'sports-science')
      AND overview IS NOT NULL AND overview <> '';
    IF n <> 22 THEN
        RAISE EXCEPTION 'expected 22 design/hospitality/sports specializations with an overview, found % -- a slug did not match', n;
    END IF;

    -- THE CLOSING ASSERTION OF THE SERIES. Every specialization in the catalogue
    -- must now carry an overview. Stated over the whole table on purpose: this is
    -- the invariant the thirteen migrations existed to establish, and from here a
    -- specialization added without one is a defect the next boot should surface
    -- rather than something to discover on the live page months later.
    SELECT count(*), string_agg(slug, ', ' ORDER BY slug) INTO n, bad
    FROM specializations WHERE overview IS NULL OR btrim(overview) = '';
    IF n > 0 THEN
        RAISE EXCEPTION '% specialization(s) have no overview after the final batch: %', n, bad;
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
