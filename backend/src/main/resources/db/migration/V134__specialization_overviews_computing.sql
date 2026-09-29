-- Overviews for the Computer Science and Information Technology specializations.
--
-- 262 of 263 specializations have overview IS NULL. That is not a blank card on
-- the page -- specializations/[slug] falls back to `description`, and every one
-- of those descriptions is the generated stub "X is a specialization within Y."
-- So today 262 pages render a card headed "What You Will Learn" whose entire
-- body restates the page title. A heading that promises content and delivers a
-- tautology is worse than one that is absent, and it is 262 pages of it, all of
-- them in sitemap.xml.
--
-- This is the first of several batches, grouped by parent career so each one
-- stays reviewable. 23 rows here: 15 under Computer Science & Engineering, 8
-- under Information Technology.
--
-- WHAT THESE SAY AND DO NOT SAY. Each overview names the actual subject matter
-- -- the topics, the mathematics, the tools -- because that is definitional and
-- checkable against any university syllabus. None of them claims a salary, a
-- hiring trend, a placement rate or a "growing demand", which is the direction
-- this kind of copy usually drifts and which would be invented. salary_min_lpa,
-- salary_max_lpa and `demand` are separate columns and stay untouched here.
--
-- THE CSE/IT SPLIT IS MADE EXPLICIT rather than blurred. Several pairs look like
-- duplicates across the two careers -- cybersecurity/it-security,
-- computer-networks/network-administration, database-systems/database-
-- administration, computer-systems/systems-administration. They are not
-- duplicates: the CSE side is designing and reasoning about the system, the IT
-- side is running and defending one in production. A student comparing the two
-- pages is asking exactly that question, so each overview says which side it is
-- on. Writing them as interchangeable would hide the only distinction that
-- matters here.

UPDATE specializations SET overview = v.overview
FROM (VALUES

-- ----------------------------------------------- Computer Science & Engineering

('blockchain',
 'This specialization covers distributed ledgers and the cryptography that makes them tamper-evident: hash functions and Merkle trees, public-key signatures, and consensus mechanisms such as proof of work and proof of stake. You will write and test smart contracts, usually in Solidity against the Ethereum Virtual Machine, and study where a ledger genuinely solves a trust problem and where an ordinary database would do the job better.'),

('cloud-computing',
 'This specialization covers building systems that run on rented infrastructure rather than machines you own: virtualization and containers, the IaaS, PaaS and serverless models, and the managed storage, networking and identity services of at least one major provider. Expect hands-on work with autoscaling, availability zones, infrastructure-as-code, and the cost modelling that separates an architecture that works from one that is affordable.'),

('computer-graphics',
 'This specialization covers how images are produced from geometry and light: the rasterization pipeline, ray tracing, texture mapping, and shading and illumination models. It leans heavily on linear algebra and geometry, and you will program the GPU directly through shaders in OpenGL, Vulkan or a similar API rather than only using a finished engine.'),

('computer-networks',
 'This specialization covers how data moves between machines: the layered model, Ethernet and wireless links, IP addressing and routing, TCP and UDP, and the application protocols built on them including DNS, HTTP and TLS. Expect socket programming, packet-level analysis with tools like Wireshark, and the design questions of congestion control and reliability. It is the design-and-theory side of networking; Network Administration under Information Technology is the operational counterpart.'),

('computer-systems',
 'This specialization covers the layers between a program and the hardware it runs on: instruction set architecture, pipelining, the cache and memory hierarchy, operating system internals such as scheduling and virtual memory, and how a compiler turns source into machine code. Expect to work close to the metal in C and assembly, and to reason about performance in terms of what the hardware is actually doing.'),

('cybersecurity',
 'This specialization covers attacking and defending systems from first principles: symmetric and public-key cryptography, authentication and access control, common vulnerability classes such as injection, memory corruption and broken authentication, network and web application security, and digital forensics. Expect substantial lab work in which you exploit deliberately weak systems in order to understand how they are hardened.'),

('data-engineering',
 'This specialization covers moving and shaping data so that analysis and machine learning have something reliable to run on: batch and streaming ingestion, data modelling for warehouses and lakes, distributed processing with engines such as Spark, and workflow orchestration. Expect strong SQL throughout, along with the less glamorous core of the discipline -- schema evolution, data quality checks, idempotent reprocessing and backfills.'),

('database-systems',
 'This specialization covers how a database is built and why it behaves as it does: the relational model and normalization, indexing and storage layout, query planning and optimisation, transactions and the ACID properties, concurrency control and recovery, and where NoSQL models trade one of these away for another. It is the internals-and-design view; Database Administration under Information Technology is the operational one.'),

('devops-and-platform-engineering',
 'This specialization covers the path from a commit to running software and keeping it running: version control workflows, continuous integration and deployment pipelines, containers and orchestration with Kubernetes, infrastructure-as-code, and observability through metrics, logs and traces. Expect a working knowledge of Linux and scripting, and practice with release strategies, rollbacks and incident response.'),

('distributed-systems',
 'This specialization covers systems whose parts run on separate machines and fail independently: replication, partitioning, consistency models from linearizable to eventual, consensus protocols such as Raft and Paxos, and fault tolerance. Expect the theory that constrains the design -- the CAP and FLP results, failure detectors, logical clocks -- alongside implementation of the patterns real systems use.'),

('game-development',
 'This specialization covers building interactive real-time software: the game loop, real-time rendering, physics and collision detection, animation, audio, and gameplay and AI programming. Work is usually in C++ or C# inside an engine such as Unreal or Unity, with a consistent emphasis on performance because everything has to finish inside a frame. Game Design under Design is the neighbouring discipline concerned with rules and player experience rather than implementation.'),

('internet-of-things',
 'This specialization covers connecting physical devices to networks and to each other: microcontrollers and sensors, embedded programming usually in C or C++, low-power and short-range wireless protocols, messaging patterns such as MQTT, and edge and gateway architectures. Expect to build working hardware rather than only simulate it, and to deal with power budgets, intermittent connectivity and device security.'),

('mobile-application-development',
 'This specialization covers building applications for phones and tablets: native Android in Kotlin, native iOS in Swift, or a cross-platform framework such as Flutter or React Native. Expect the constraints that define the platform -- the activity and view lifecycle, offline behaviour and local storage, background execution limits, battery and network use, and the review and release process of each app store.'),

('software-engineering',
 'This specialization covers building software that a team can keep working on: requirements and specification, design and architecture, design patterns, testing at unit, integration and system level, version control and code review, refactoring, and agile process. It is the discipline of the whole lifecycle rather than of one technology, and the emphasis falls on the parts that decide whether a codebase survives its second year.'),

('web-development',
 'This specialization covers building applications delivered through a browser: HTML, CSS and JavaScript, a component framework such as React, and server-side work with APIs, databases, authentication and sessions. Expect HTTP and REST to be treated as fundamentals rather than details, along with accessibility, responsive layout, performance, and deploying and monitoring what you have built.'),

-- -------------------------------------------------------- Information Technology

('database-administration',
 'This specialization covers keeping a database running in production: installation and configuration, user and privilege management, backup and point-in-time recovery, replication and high availability, monitoring, and performance tuning through indexes, statistics and query plans. Expect tested restores and upgrade and migration procedures, on one or more of PostgreSQL, MySQL, Oracle and SQL Server. Database Systems under Computer Science covers how these engines work internally.'),

('enterprise-applications',
 'This specialization covers the large packaged systems a business runs on -- ERP, CRM and HRMS platforms such as SAP, Oracle or Salesforce -- and the work of fitting them to an organisation: mapping business processes, configuring and extending rather than rebuilding, integrating with other systems, migrating data, and supporting users after go-live. Understanding the finance, sales and supply-chain processes involved matters as much here as the technology does.'),

('it-infrastructure',
 'This specialization covers the physical and virtual foundation that applications run on: servers, storage systems and RAID, networking hardware, virtualization and hypervisors, data centre power, cooling and racking, and the hybrid arrangements that connect on-premise equipment to cloud providers. Expect capacity planning, hardware lifecycle and procurement, and backup and disaster recovery design.'),

('it-operations',
 'This specialization covers running services day to day and keeping them available: monitoring and alerting, incident, problem and change management, runbooks and automation, patching, scheduled maintenance, capacity and performance review, and on-call rotation. Much of the skill is diagnostic -- reading logs and metrics under time pressure to find what changed -- and much of the rest is writing things down so the next person can do it.'),

('it-security',
 'This specialization covers defending an organisation''s systems and data in operation: identity and access management, endpoint and server hardening, patch and vulnerability management, firewalls and network segmentation, log collection and monitoring through a SIEM, incident response, and the policy, audit and compliance work that surrounds all of it. Cybersecurity under Computer Science covers the same ground from the attacker''s and the cryptographer''s side.'),

('it-service-management',
 'This specialization covers organising IT as a service to the people who depend on it, generally through the ITIL framework: the service desk and ticket lifecycle, incident, problem, change and release management, the service catalogue, service level agreements and their reporting, and continual improvement. It is a process and governance discipline, and the technical work sits inside it rather than the other way round.'),

('network-administration',
 'This specialization covers running an organisation''s network: switch and router configuration, VLANs and subnetting, routing protocols, firewalls, VPNs and remote access, wireless deployment, DHCP and DNS services, and monitoring and troubleshooting when something stops working. Expect hands-on configuration on real or simulated equipment. Computer Networks under Computer Science covers the protocols and design theory underneath.'),

('systems-administration',
 'This specialization covers administering servers and the operating systems on them: Linux and Windows Server installation and configuration, user and group management, filesystems and storage, services and startup, scheduled jobs, patching, directory services such as Active Directory and LDAP, and automation through shell or PowerShell scripting and a configuration management tool. Computer Systems under Computer Science covers operating system internals rather than their operation.')

) AS v(slug, overview)
WHERE specializations.slug = v.slug;

DO $$
DECLARE n int; bad text;
BEGIN
    -- Counted over this batch's two careers rather than over the whole table. A
    -- global total would be a snapshot: correct the day it is written and wrong
    -- the moment a later migration or an admin adds a specialization, which is
    -- how V80 and V101 ended up unreplayable. This form stays true forever.
    --
    -- 24, not the 23 written above: artificial-intelligence-and-machine-learning
    -- also sits under Computer Science & Engineering and already had an overview,
    -- which is why it is absent from the VALUES list.
    SELECT count(*) INTO n FROM specializations
    WHERE primary_career_slug IN ('computer-science-and-engineering', 'information-technology')
      AND overview IS NOT NULL AND overview <> '';
    IF n <> 24 THEN
        RAISE EXCEPTION 'expected 24 computing specializations with an overview, found % -- a slug did not match', n;
    END IF;

    -- Every specialization under these two careers must now be covered. Stated
    -- relationally rather than as a count so the assertion still holds if a
    -- specialization is added or moved later: it will fail and say which.
    SELECT count(*), string_agg(slug, ', ' ORDER BY slug) INTO n, bad
    FROM specializations
    WHERE primary_career_slug IN ('computer-science-and-engineering', 'information-technology')
      AND (overview IS NULL OR overview = '');
    IF n > 0 THEN
        RAISE EXCEPTION '% computing specialization(s) still have no overview: %', n, bad;
    END IF;

    -- An overview must say more than the generated description does. Copying the
    -- stub in would satisfy NOT NULL while leaving the page exactly as it was.
    SELECT count(*), string_agg(slug, ', ' ORDER BY slug) INTO n, bad
    FROM specializations
    WHERE overview IS NOT NULL AND btrim(overview) = btrim(coalesce(description, ''));
    IF n > 0 THEN
        RAISE EXCEPTION '% overview(s) merely repeat the description: %', n, bad;
    END IF;

    -- Length bounds. The floor rejects a one-line stub; the ceiling catches an
    -- overview long enough to break the fixed-height card it renders in.
    SELECT count(*), string_agg(slug || ' (' || length(btrim(overview)) || ')', ', ' ORDER BY slug)
    INTO n, bad
    FROM specializations
    WHERE overview IS NOT NULL
      AND length(btrim(overview)) NOT BETWEEN 200 AND 800;
    IF n > 0 THEN
        RAISE EXCEPTION '% overview(s) fall outside 200-800 characters: %', n, bad;
    END IF;

    -- These overviews are deliberately free of pay and demand claims: those
    -- belong in salary_min_lpa, salary_max_lpa and `demand`, which this
    -- migration does not touch. Asserted so a later edit cannot quietly move an
    -- unsourced number into prose, where nothing validates it.
    SELECT count(*), string_agg(slug, ', ' ORDER BY slug) INTO n, bad
    FROM specializations
    WHERE overview IS NOT NULL
      AND (overview ~* '\y(lpa|lakh|crore|salary|package|ctc)\y' OR overview LIKE '%₹%');
    IF n > 0 THEN
        RAISE EXCEPTION '% overview(s) contain a pay claim, which belongs in the salary columns: %', n, bad;
    END IF;
END $$;
