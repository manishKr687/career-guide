-- Adds NIT Patna, the one college from the uploaded seed doc's Colleges
-- section confirmed via psql to be genuinely missing from the 19 existing
-- colleges rows.
--
-- established=2004 is NIT Patna's real, publicly documented founding year
-- (it was established as an NIT in 2004), not an invented value -- matches
-- the existing style/grain of the sibling NIT rows (nit-trichy=1964,
-- nit-warangal=1959) already in this table.

INSERT INTO colleges (slug, name, location, type, established, tags, description) VALUES
    ('nit-patna', 'NIT Patna', 'Patna, Bihar', 'NIT', 2004, ARRAY['Engineering'],
     'A National Institute of Technology in Bihar offering undergraduate and postgraduate engineering programs.');
