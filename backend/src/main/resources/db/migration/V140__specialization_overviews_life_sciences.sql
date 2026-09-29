-- Overviews for the Biology, Biotechnology, Agriculture and Forestry
-- specializations. Seventh batch; V134 explains rationale and exclusions.
--
-- 22 rows: 7 under Biology, 6 under Biotechnology, 5 under Agriculture, 4 under
-- Forestry.
--
-- BIOLOGY AND BIOTECHNOLOGY SHARE MOST OF THEIR TECHNIQUES, and the overviews
-- separate them by purpose rather than by content: Biology's Molecular Biology
-- and Genetics study how the mechanism works, while Biotechnology's Genetic
-- Engineering and Bioprocess Engineering use it to make something. The same PCR
-- machine appears in both; the question being asked of it differs.
--
-- INDIAN STATUTE AND REGULATORS ARE NAMED where they define the practice -- the
-- GEAC for anything transgenic, the Wild Life (Protection) Act 1972 and Forest
-- (Conservation) Act 1980 for conservation work. Named only; no provision or
-- schedule is paraphrased from memory.

UPDATE specializations SET overview = v.overview
FROM (VALUES

-- --------------------------------------------------------------------- Biology

('botany',
 'This specialization covers plants as organisms and as a kingdom: morphology and anatomy, taxonomy and systematics, plant physiology from photosynthesis and respiration to growth regulators and water relations, reproduction and embryology, and the diversity of algae, fungi, bryophytes, pteridophytes, gymnosperms and angiosperms. Expect plant pathology, plant ecology, economic botany and tissue culture, with herbarium and microscopy practice throughout.'),

('cell-biology',
 'This specialization covers the cell as a working unit: membrane structure and transport, the organelles and their functions, protein sorting and trafficking, the cytoskeleton and cell motility, the cell cycle and its checkpoints, mitosis and meiosis, cell signalling and receptor pathways, cell adhesion and the extracellular matrix, and programmed cell death. Expect microscopy, cell culture, fractionation and immunostaining as the working techniques.'),

('ecology',
 'This specialization covers how organisms relate to each other and their surroundings: population growth, regulation and life history, competition, predation and mutualism, community structure and succession, ecosystem energy flow and nutrient cycling, biodiversity and biogeography, and applied conservation and restoration ecology. Field sampling design and quantitative analysis are central, since almost every conclusion here is statistical.'),

('genetics',
 'This specialization covers inheritance and variation: Mendelian and non-Mendelian inheritance, linkage, recombination and genetic mapping, chromosome structure and aberrations, mutation and DNA repair, gene interaction, population genetics and evolutionary change, quantitative and cytogenetics, and human and medical genetics. Model organisms are used throughout, and molecular methods are treated as the modern continuation of classical genetic analysis.'),

('microbiology',
 'This specialization covers organisms too small to see: bacterial structure and classification, viruses and bacteriophages, fungi, algae and protozoa, microbial metabolism and growth kinetics, culture media and enumeration, sterilisation and control, microbial genetics, and immunology. Expect the applied divisions -- medical, food, industrial, agricultural and environmental microbiology -- and rigorous aseptic technique, staining and identification in the laboratory.'),

('molecular-biology',
 'This specialization covers the molecular mechanism of heredity and its expression: DNA structure and replication, transcription and RNA processing, translation and the genetic code, regulation of gene expression in prokaryotes and eukaryotes, chromatin and epigenetics, and DNA repair and recombination. Expect the technique set that follows from it -- cloning, PCR and its variants, blotting, sequencing, expression analysis and CRISPR-based editing.'),

('zoology',
 'This specialization covers animals across the phyla: invertebrate and vertebrate diversity and classification, comparative anatomy and physiology of the organ systems, developmental biology and embryology, evolution and phylogeny, animal behaviour, and ecology and wildlife biology. Expect parasitology, entomology and applied areas such as fisheries and sericulture, with dissection, microscopy and specimen study as the practical core.'),

-- --------------------------------------------------------------- Biotechnology

('agricultural-biotechnology',
 'This specialization covers applying molecular tools to crops and livestock: plant tissue culture and micropropagation, molecular markers and marker-assisted selection, genetic transformation and transgenic crops for insect resistance and herbicide tolerance, genomic selection, abiotic stress tolerance, and biofertilisers, biopesticides and biocontrol agents. Field trials and the GEAC approval regime for transgenic material in India are part of the subject.'),

('bioinformatics',
 'This specialization covers extracting biological meaning from sequence and structure data: biological databases, pairwise and multiple sequence alignment, BLAST and homology searching, phylogenetic inference, genome assembly and annotation, next-generation sequencing pipelines for variant calling and RNA-seq, protein structure prediction and molecular docking, and systems-level network analysis. Programming in Python or R and applied statistics are prerequisites rather than extras.'),

('bioprocess-engineering',
 'This specialization covers manufacturing with living cells: media formulation and inoculum development, fermentation kinetics and yield, bioreactor design, instrumentation and operating modes from batch to fed-batch and continuous, sterile operation, oxygen transfer and mixing, and the downstream train of separation, disruption, purification and formulation. Scale-up and operation under good manufacturing practice are the defining constraints.'),

('genetic-engineering',
 'This specialization covers deliberately altering an organism''s genetic material: restriction enzymes, vectors and host systems, cloning and library construction, expression of recombinant proteins in bacterial, yeast, insect and mammalian systems, site-directed mutagenesis, gene silencing, genome editing with CRISPR-Cas and its predecessors, and transgenic plants and animals. Biosafety levels, containment and the ethics and regulation of the work are treated as part of it.'),

('industrial-biotechnology',
 'This specialization covers biology as a manufacturing route: industrially useful microorganisms and enzymes, enzyme production, immobilisation and engineering, fermentation-derived products including antibiotics, organic acids, amino acids, vitamins and single cell protein, biofuels and biopolymers, biotransformation as an alternative to chemical synthesis, and bioremediation. Process economics decides which of these is viable, so it is studied alongside the biology.'),

('pharmaceutical-biotechnology',
 'This specialization covers biologically derived medicines: recombinant therapeutic proteins, monoclonal antibodies, vaccines including recombinant and mRNA platforms, and cell and gene therapy. Expect mammalian cell culture upstream, chromatographic purification downstream, formulation and stability, bioanalytical characterisation and potency assay, and the regulatory path from preclinical work through clinical phases, with biosimilars and quality-by-design as recurring themes.'),

-- ----------------------------------------------------------------- Agriculture

('agricultural-economics',
 'This specialization covers the economics of farming and food: production economics and resource allocation on the farm, farm management and budgeting, agricultural marketing, price behaviour and market structure, agricultural finance and rural credit, risk and crop insurance, and policy instruments including minimum support prices, procurement and subsidies. Expect econometric analysis of farm and market data, and international trade in agricultural commodities.'),

('agricultural-engineering',
 'This specialization covers the engineering that farming depends on: farm power and tractors, tillage and sowing implements and their performance, irrigation engineering including surface, sprinkler and drip systems, drainage, soil and water conservation structures, watershed development, post-harvest processing, drying and storage, farm structures, and renewable energy on the farm. Precision agriculture with GPS guidance and remote sensing is the newer layer.'),

('agronomy',
 'This specialization covers growing field crops well: crop production practice for cereals, pulses, oilseeds, fibre and fodder crops, cropping systems, rotation and intercropping, tillage and seedbed preparation, sowing time and geometry, irrigation scheduling and water use efficiency, integrated nutrient management, and weed control. Field experimentation and its statistical design underlie the recommendations rather than sitting beside them.'),

('horticulture',
 'This specialization covers intensively cultivated crops and their handling: fruit, vegetable, flower, plantation, spice and medicinal crops, nursery management and propagation by cutting, grafting and layering, orchard establishment, training and pruning, protected cultivation under polyhouse and shade net, growth regulators, and post-harvest handling, grading, packaging and cold chain. Landscaping and floriculture form a distinct applied branch.'),

('soil-science',
 'This specialization covers soil as a material and as a living system: formation, classification and survey, physical properties including texture, structure and water retention, soil chemistry and colloidal behaviour, cation exchange and pH, organic matter and soil biology, nutrient availability and fertiliser response, and the diagnosis and reclamation of saline, sodic and acidic soils. Soil testing and analysis are the practical foundation of the discipline.'),

-- -------------------------------------------------------------------- Forestry

('conservation',
 'This specialization covers protecting biodiversity in practice: species and habitat assessment, threatened species status and recovery planning, protected area design and management across national parks, sanctuaries and reserves, in-situ and ex-situ approaches, habitat restoration, and the mitigation of human-wildlife conflict. The legal framework -- principally the Wild Life (Protection) Act 1972 and the Forest (Conservation) Act 1980 -- and community-based and joint forest management shape what is possible.'),

('forest-economics',
 'This specialization covers the economic valuation of forests and the decisions that follow: timber and non-timber forest product valuation, forest resource economics, determining rotation age and optimal harvest scheduling, investment appraisal of plantation projects, the valuation of ecosystem services including watershed protection and carbon sequestration, carbon markets and payment for ecosystem services, and forest policy, tenure and trade.'),

('forest-management',
 'This specialization covers managing a forest as a renewable resource: silvicultural systems and regeneration, forest mensuration -- measuring volume, growth and increment -- inventory and sampling design, working plan preparation, nursery and plantation practice, thinning and harvesting, and agroforestry and social forestry. Expect remote sensing and GIS for mapping and change detection, and forest protection against fire, grazing, pests and encroachment.'),

('wildlife-management',
 'This specialization covers managing animal populations and their habitat: population estimation by line transect, camera trap, mark-recapture and sign survey, habitat evaluation and carrying capacity, radio and satellite telemetry, movement and corridor analysis, translocation and reintroduction, captive management and breeding, conflict mitigation, and anti-poaching enforcement and wildlife forensics. Field methods and their statistical analysis are the core competence.')

) AS v(slug, overview)
WHERE specializations.slug = v.slug;

DO $$
DECLARE n int; bad text;
BEGIN
    SELECT count(*) INTO n FROM specializations
    WHERE primary_career_slug IN ('biology', 'biotechnology', 'agriculture', 'forestry')
      AND overview IS NOT NULL AND overview <> '';
    IF n <> 22 THEN
        RAISE EXCEPTION 'expected 22 life-science specializations with an overview, found % -- a slug did not match', n;
    END IF;

    SELECT count(*), string_agg(slug, ', ' ORDER BY slug) INTO n, bad
    FROM specializations
    WHERE primary_career_slug IN ('biology', 'biotechnology', 'agriculture', 'forestry')
      AND (overview IS NULL OR overview = '');
    IF n > 0 THEN
        RAISE EXCEPTION '% life-science specialization(s) still have no overview: %', n, bad;
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
