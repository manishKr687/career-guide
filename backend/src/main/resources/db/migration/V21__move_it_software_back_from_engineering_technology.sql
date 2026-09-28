-- Reverses V18 for exactly the 4 original IT & Software careers -- Data
-- Scientist, Software Engineer, Cybersecurity Analyst, Cloud Architect --
-- moving them back out of Engineering & Technology into IT & Software.
--
-- Computer Science Engineer (added in V20, after V18/V19) is a genuinely
-- new Engineering & Technology career in its own right and is NOT part of
-- this reversal -- it stays exactly where V20 put it, per explicit scope
-- ("the original 4 only").
--
-- IT & Software is currently empty (0 careers) after V18, so sort_order
-- 0..3 below is a fresh sequence with no collision risk.

UPDATE careers SET category_slug = 'it-software', sort_order = 0 WHERE slug = 'data-scientist';
UPDATE careers SET category_slug = 'it-software', sort_order = 1 WHERE slug = 'software-engineer';
UPDATE careers SET category_slug = 'it-software', sort_order = 2 WHERE slug = 'cybersecurity-analyst';
UPDATE careers SET category_slug = 'it-software', sort_order = 3 WHERE slug = 'cloud-architect';

-- ---------------------------------------------------------------------
-- Symmetric reversal of the assessment-scoring merge from V18. V18 moved
-- these 7 assessment_option_weights rows (option_ids 33, 35, 23, 25, 13, 5,
-- 29) from category_slug='it-software' to 'engineering-technology' so that
-- a user scoring highest on IT & Software wouldn't be routed to a category
-- with zero recommendable careers. Now that IT & Software has its 4
-- careers back, leaving these rows pointed at engineering-technology would
-- reintroduce the exact asymmetry V18 was fixing, just in the other
-- direction (engineering-technology's own weight would be inflated by
-- weights that really belong to IT & Software questions/options).
--
-- Confirmed via query before writing this migration: none of these 7
-- option_ids currently has an existing category_slug='it-software' row, so
-- this rename cannot collide with the (option_id, category_slug) primary
-- key.
-- ---------------------------------------------------------------------

UPDATE assessment_option_weights
SET category_slug = 'it-software'
WHERE category_slug = 'engineering-technology'
  AND option_id IN (33, 35, 23, 25, 13, 5, 29);
