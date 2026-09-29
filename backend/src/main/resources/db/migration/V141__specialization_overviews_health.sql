-- Overviews for the Medicine, Nursing, Pharmacy and Physiotherapy
-- specializations. Eighth batch; V134 explains rationale and exclusions.
--
-- 23 rows: 9 under Medicine, 5 under Nursing, 5 under Pharmacy, 4 under
-- Physiotherapy.
--
-- THE MEDICAL ONES NAME THE TRAINING ROUTE, because that is the single most
-- useful and most misunderstood fact about them. A student reading "Cardiology"
-- on a careers site generally does not know it is not a course you join after
-- MBBS: it is a DM taken after an MD in General Medicine, entered through
-- NEET-SS, which makes it around six years of postgraduate training rather than
-- three. Getting that wrong changes a student's entire plan, so each overview
-- says which degree it is and what precedes it.
--
-- WHY THESE ROUTES AND NOT NUMBERS. The structure -- MBBS, then MD or MS through
-- NEET-PG, then DM or MCh through NEET-SS, with the DNB route in parallel -- is
-- durable and checkable. Seat counts, cut-offs and stipends are none of those
-- things and appear nowhere here.
--
-- NO OVERVIEW GIVES CLINICAL GUIDANCE. These describe what a speciality studies
-- and treats, at the level of a prospectus. Naming a condition is descriptive;
-- naming a drug, dose or protocol would be neither useful here nor safe, and is
-- absent throughout.

UPDATE specializations SET overview = v.overview
FROM (VALUES

-- -------------------------------------------------------------------- Medicine

('cardiology',
 'This specialization covers the heart and circulation: coronary artery disease, heart failure, valvular and congenital heart disease, rhythm disorders, and hypertension. Training is interventional as well as diagnostic -- echocardiography, catheterisation and angiography, angioplasty, pacing and electrophysiology. In India it is a super-speciality: a DM in Cardiology entered through NEET-SS after completing an MD in General Medicine, so it follows rather than replaces general medical training.'),

('dermatology',
 'This specialization covers the skin, hair, nails and mucosae: inflammatory conditions such as eczema and psoriasis, infections, acne, autoimmune and blistering disease, pigmentary disorders, skin cancers, and the cutaneous signs of systemic illness. The Indian qualification is an MD in Dermatology, Venereology and Leprosy, taken through NEET-PG, and the scope formally includes sexually transmitted infections and leprosy alongside general and procedural dermatology.'),

('general-medicine',
 'This specialization covers the diagnosis and non-surgical management of adult illness across every organ system -- cardiovascular, respiratory, gastrointestinal, renal, endocrine, neurological, haematological and infectious disease. It is the broadest of the clinical specialities and the base from which most super-specialities are entered. The qualification is an MD in General Medicine through NEET-PG, and clinical reasoning from history and examination is the skill it is built around.'),

('neurology',
 'This specialization covers the brain, spinal cord, nerves and muscles: stroke, epilepsy, headache disorders, multiple sclerosis and other demyelinating disease, movement disorders including Parkinson''s, dementia, neuromuscular and peripheral nerve disease, and neuroinfection. Expect neurological localisation as the central skill, supported by EEG, nerve conduction and imaging. It is a DM entered through NEET-SS after an MD in General Medicine.'),

('oncology',
 'This specialization covers the diagnosis and treatment of cancer, and divides by the modality used: medical oncology delivering systemic therapy including chemotherapy, targeted agents and immunotherapy; radiation oncology planning and delivering radiotherapy; and surgical oncology. Practice is by multidisciplinary team, with staging, pathology and molecular profiling determining the plan. In India the routes differ by branch -- a DM in Medical Oncology, an MD in Radiation Oncology, or an MCh in Surgical Oncology.'),

('orthopedics',
 'This specialization covers bones, joints, ligaments, tendons and the spine: fractures and trauma, arthritis and joint replacement, sports injuries and arthroscopy, spinal disorders, bone infection and tumours, paediatric and congenital deformity, and hand and reconstructive surgery. Training is surgical and instrument-heavy, and includes fracture fixation, implants and rehabilitation planning. The qualification is an MS in Orthopaedics through NEET-PG.'),

('pediatrics',
 'This specialization covers the health of children from newborn to adolescent: growth and development and its deviations, neonatology and preterm care, immunisation, nutrition and deficiency disorders, childhood infections, congenital and genetic disease, and the paediatric presentation of respiratory, cardiac, neurological and renal conditions. Dosing, physiology and communication all differ from adult practice. The qualification is an MD in Paediatrics through NEET-PG.'),

('psychiatry',
 'This specialization covers mental illness and its treatment: mood disorders, anxiety and obsessive-compulsive disorders, schizophrenia and other psychoses, substance use disorders, child and adolescent psychiatry, geriatric psychiatry, and the psychiatric aspects of physical illness. Training covers psychopharmacology, psychotherapeutic methods, and the legal framework around capacity and involuntary treatment. The qualification is an MD in Psychiatry through NEET-PG.'),

('surgery',
 'This specialization covers conditions treated by operation: abdominal and gastrointestinal surgery, hernia, hepatobiliary and endocrine surgery, trauma, burns, breast and vascular surgery, and the management that surrounds the operation -- preoperative assessment, anaesthetic liaison, fluid and nutritional support, and postoperative complications. Open, laparoscopic and increasingly robotic technique are all taught. The qualification is an MS in General Surgery through NEET-PG, and it is the base for several MCh super-specialities.'),

-- --------------------------------------------------------------------- Nursing

('community-nursing',
 'This specialization covers nursing delivered outside hospital, in homes and neighbourhoods: home visiting and family health assessment, maternal and child health and antenatal care, immunisation, family planning and reproductive health counselling, nutrition education, communicable disease surveillance and control, and non-communicable disease screening. Expect the structure of India''s primary health system and the national health programmes to be studied as the working context.'),

('critical-care',
 'This specialization covers nursing the most unstable patients: haemodynamic and ventilator monitoring and its interpretation, airway and ventilation care, vasoactive and sedative infusions, fluid and electrolyte balance, renal replacement, nutrition, infection prevention in the ICU, pressure area and mobility care, and recognition of deterioration early enough to act. Communication with families facing poor outcomes is treated as part of the skill set.'),

('emergency-nursing',
 'This specialization covers the first hours of acute illness and injury: triage and rapid assessment, resuscitation and advanced life support, airway and haemorrhage control, trauma and burns management, poisoning, obstetric and paediatric emergencies, and disaster and mass casualty response. It is defined by working with incomplete information under time pressure, and by the documentation and handover discipline that makes that safe.'),

('general-nursing',
 'This specialization covers the foundation of nursing practice across medical and surgical wards: patient assessment and vital sign interpretation, the nursing process and care planning, medication administration and its safety checks, wound and stoma care, catheter and drain management, pre- and postoperative care, infection control, mobility and pressure injury prevention, nutrition, patient education and accurate documentation.'),

('pediatric-nursing',
 'This specialization covers nursing infants, children and adolescents: neonatal and preterm care, growth and development monitoring, weight-based medication calculation and the narrow margins it allows, paediatric assessment and pain scoring in children who cannot describe symptoms, care of the child with respiratory, cardiac, oncological or congenital conditions, immunisation, and work with parents as part of the care team rather than as visitors.'),

-- -------------------------------------------------------------------- Pharmacy

('clinical-pharmacy',
 'This specialization covers the pharmacist''s role in patient care rather than in dispensing: medication history and reconciliation, dose review and adjustment for renal and hepatic function, drug interaction and contraindication screening, therapeutic drug monitoring, adverse drug reaction detection and pharmacovigilance reporting, patient counselling and adherence, and participation in ward rounds. Evidence appraisal and the literature are working tools.'),

('drug-development',
 'This specialization covers the path from a molecule to an approved medicine: target identification and lead discovery, preclinical pharmacology and toxicology, pharmacokinetic and ADME profiling, formulation and stability, and the clinical phases from first-in-human safety through efficacy trials to post-marketing surveillance. Expect trial design and good clinical practice, regulatory dossier preparation, and the Indian approval route alongside its international counterparts.'),

('industrial-pharmacy',
 'This specialization covers manufacturing medicines at scale: preformulation and dosage form design for tablets, capsules, parenterals, semisolids and transdermal systems, unit operations including granulation, compression, coating, sterilisation and lyophilisation, packaging and stability testing, and process validation. Good manufacturing practice, quality assurance and quality control, and documentation and audit readiness define how the work is actually done.'),

('pharmaceutical-research',
 'This specialization covers the discovery end of pharmacy: medicinal chemistry and structure-activity relationships, computer-aided drug design and molecular docking, synthesis and purification of candidate molecules, in-vitro assay development and screening, analytical method development and validation, natural product isolation, and novel drug delivery systems including nanoparticulate and targeted carriers. Instrumental analysis and literature work are continuous.'),

('pharmacology',
 'This specialization covers how drugs act on the body and the body on drugs: receptor theory, dose-response and agonism, pharmacokinetics from absorption through distribution and metabolism to excretion, and systematic pharmacology of the autonomic, cardiovascular, central nervous, endocrine and immune systems along with chemotherapy and antimicrobials. Toxicology, adverse effects and interactions, and experimental and screening methods complete it.'),

-- --------------------------------------------------------------- Physiotherapy

('neurological-physiotherapy',
 'This specialization covers restoring movement after damage to the nervous system: assessment of tone, strength, sensation, balance and gait, and rehabilitation after stroke, traumatic brain and spinal cord injury, and in Parkinson''s disease, multiple sclerosis, cerebral palsy and peripheral nerve injury. Expect neuroplasticity-based approaches, task-specific and repetitive training, functional electrical stimulation, gait retraining, spasticity management and orthotic and mobility aid prescription.'),

('orthopedic-physiotherapy',
 'This specialization covers musculoskeletal assessment and treatment: joint range and muscle strength testing, special tests for ligament and tendon integrity, posture and movement analysis, and rehabilitation after fracture, arthroplasty, arthroscopy and soft tissue injury, plus conservative management of back and neck pain and arthritis. Manual therapy and mobilisation, therapeutic exercise progression, taping and electrotherapy are the working methods.'),

('pediatric-physiotherapy',
 'This specialization covers the physical development of children and its disorders: developmental assessment against milestones, and management of cerebral palsy, spina bifida, muscular dystrophy, torticollis, talipes and postural deformity, along with respiratory physiotherapy for children and care of the preterm infant. Treatment is delivered through play and through parents, since a child''s home programme carries most of the therapeutic load.'),

('sports-physiotherapy',
 'This specialization covers the injured and the training athlete: injury mechanism and pitch-side assessment, immediate management, and staged rehabilitation of sprains, strains, ligament ruptures and overuse injury with objective return-to-play criteria. Expect screening for injury risk, load and workload management, strength and conditioning principles, taping and bracing, recovery strategy, and work alongside coaches and sports physicians rather than in isolation.')

) AS v(slug, overview)
WHERE specializations.slug = v.slug;

DO $$
DECLARE n int; bad text;
BEGIN
    SELECT count(*) INTO n FROM specializations
    WHERE primary_career_slug IN ('medicine', 'nursing', 'pharmacy', 'physiotherapy')
      AND overview IS NOT NULL AND overview <> '';
    IF n <> 23 THEN
        RAISE EXCEPTION 'expected 23 health specializations with an overview, found % -- a slug did not match', n;
    END IF;

    SELECT count(*), string_agg(slug, ', ' ORDER BY slug) INTO n, bad
    FROM specializations
    WHERE primary_career_slug IN ('medicine', 'nursing', 'pharmacy', 'physiotherapy')
      AND (overview IS NULL OR overview = '');
    IF n > 0 THEN
        RAISE EXCEPTION '% health specialization(s) still have no overview: %', n, bad;
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
