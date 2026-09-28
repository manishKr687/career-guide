-- Adds a second layer of "deep dive" assessment questions, one per broad
-- career cluster (tech, science & health, creative, business, public
-- service, trades & active). These are never all shown to the same user --
-- the frontend picks ONE of these six based on how the user's answers to
-- the first two (universal) questions are trending, then asks it as the
-- next question. This is what makes the assessment feel adaptive: whichever
-- cluster the user is leaning toward, the very next question's options are
-- about that cluster specifically, instead of an unrelated generic topic.
--
-- No backend/API changes were needed for this: GET /api/assessment/questions
-- already returns every question+option+weight (see AssessmentQuestionDto),
-- and POST /api/assessment/submit already skips any question absent from
-- the submitted answers map (AssessmentService.computeCategoryScores), so a
-- user answering a subset of the full question pool works unchanged.
--
-- IDs continue from V9__seed_assessment.sql's last option id (32) rather
-- than restarting, since assessment_options.id is a shared BIGSERIAL and
-- these reference tables are only ever edited via migration (see
-- backend/README.md's "Admin panel" section), never through the admin API.

INSERT INTO assessment_questions (id, question, sort_order) VALUES ('cluster-tech', 'You''re leaning toward tech & engineering — which of these excites you most?', 8);
INSERT INTO assessment_options (id, question_id, option_key, label, sort_order) VALUES (33, 'cluster-tech', 'a', 'Writing software, apps or websites', 0);
INSERT INTO assessment_options (id, question_id, option_key, label, sort_order) VALUES (34, 'cluster-tech', 'b', 'Designing or building physical systems and machines', 1);
INSERT INTO assessment_options (id, question_id, option_key, label, sort_order) VALUES (35, 'cluster-tech', 'c', 'Working with frontier tech like AI, robotics or space', 2);
INSERT INTO assessment_options (id, question_id, option_key, label, sort_order) VALUES (36, 'cluster-tech', 'd', 'Fixing, installing or maintaining equipment hands-on', 3);

INSERT INTO assessment_questions (id, question, sort_order) VALUES ('cluster-science-health', 'You''re drawn to science & health — which direction feels right?', 9);
INSERT INTO assessment_options (id, question_id, option_key, label, sort_order) VALUES (37, 'cluster-science-health', 'a', 'Diagnosing and treating patients directly', 0);
INSERT INTO assessment_options (id, question_id, option_key, label, sort_order) VALUES (38, 'cluster-science-health', 'b', 'Research, labs and discovering how things work', 1);
INSERT INTO assessment_options (id, question_id, option_key, label, sort_order) VALUES (39, 'cluster-science-health', 'c', 'Working with crops, animals or the land', 2);
INSERT INTO assessment_options (id, question_id, option_key, label, sort_order) VALUES (40, 'cluster-science-health', 'd', 'Public health, wellness or preventive care', 3);

INSERT INTO assessment_questions (id, question, sort_order) VALUES ('cluster-creative', 'You lean creative & expressive — what pulls you in most?', 10);
INSERT INTO assessment_options (id, question_id, option_key, label, sort_order) VALUES (41, 'cluster-creative', 'a', 'Visual design — graphics, branding, UX or fashion', 0);
INSERT INTO assessment_options (id, question_id, option_key, label, sort_order) VALUES (42, 'cluster-creative', 'b', 'Writing, journalism or content creation', 1);
INSERT INTO assessment_options (id, question_id, option_key, label, sort_order) VALUES (43, 'cluster-creative', 'c', 'Film, video, photography or broadcasting', 2);
INSERT INTO assessment_options (id, question_id, option_key, label, sort_order) VALUES (44, 'cluster-creative', 'd', 'Literature, culture, languages or the humanities', 3);

INSERT INTO assessment_questions (id, question, sort_order) VALUES ('cluster-business', 'You''re business-minded — which path fits best?', 11);
INSERT INTO assessment_options (id, question_id, option_key, label, sort_order) VALUES (45, 'cluster-business', 'a', 'Numbers, markets and financial analysis', 0);
INSERT INTO assessment_options (id, question_id, option_key, label, sort_order) VALUES (46, 'cluster-business', 'b', 'Banking, insurance or financial services', 1);
INSERT INTO assessment_options (id, question_id, option_key, label, sort_order) VALUES (47, 'cluster-business', 'c', 'Leading teams and running operations', 2);
INSERT INTO assessment_options (id, question_id, option_key, label, sort_order) VALUES (48, 'cluster-business', 'd', 'Starting and building your own venture', 3);

INSERT INTO assessment_questions (id, question, sort_order) VALUES ('cluster-public-service', 'You care about service & structure — where do you see yourself?', 12);
INSERT INTO assessment_options (id, question_id, option_key, label, sort_order) VALUES (49, 'cluster-public-service', 'a', 'Civil services, public policy or administration', 0);
INSERT INTO assessment_options (id, question_id, option_key, label, sort_order) VALUES (50, 'cluster-public-service', 'b', 'Serving in the armed forces or security services', 1);
INSERT INTO assessment_options (id, question_id, option_key, label, sort_order) VALUES (51, 'cluster-public-service', 'c', 'Law, justice or advocating for others', 2);
INSERT INTO assessment_options (id, question_id, option_key, label, sort_order) VALUES (52, 'cluster-public-service', 'd', 'Teaching and shaping the next generation', 3);

INSERT INTO assessment_questions (id, question, sort_order) VALUES ('cluster-trades-active', 'You like hands-on, active work — which fits best?', 13);
INSERT INTO assessment_options (id, question_id, option_key, label, sort_order) VALUES (53, 'cluster-trades-active', 'a', 'A skilled trade — electrical, plumbing, mechanics and more', 0);
INSERT INTO assessment_options (id, question_id, option_key, label, sort_order) VALUES (54, 'cluster-trades-active', 'b', 'Sports, fitness or coaching', 1);
INSERT INTO assessment_options (id, question_id, option_key, label, sort_order) VALUES (55, 'cluster-trades-active', 'c', 'Hospitality, travel or guest-facing service', 2);
INSERT INTO assessment_options (id, question_id, option_key, label, sort_order) VALUES (56, 'cluster-trades-active', 'd', 'Outdoor, physical work with visible results', 3);

SELECT setval(pg_get_serial_sequence('assessment_options','id'), 56);

INSERT INTO assessment_option_weights (option_id, category_slug, weight) VALUES (33, 'it-software', 2);
INSERT INTO assessment_option_weights (option_id, category_slug, weight) VALUES (34, 'engineering-technology', 2);
INSERT INTO assessment_option_weights (option_id, category_slug, weight) VALUES (35, 'emerging-careers', 2);
INSERT INTO assessment_option_weights (option_id, category_slug, weight) VALUES (35, 'it-software', 1);
INSERT INTO assessment_option_weights (option_id, category_slug, weight) VALUES (36, 'skilled-trades', 2);
INSERT INTO assessment_option_weights (option_id, category_slug, weight) VALUES (36, 'engineering-technology', 1);

INSERT INTO assessment_option_weights (option_id, category_slug, weight) VALUES (37, 'medical-healthcare', 2);
INSERT INTO assessment_option_weights (option_id, category_slug, weight) VALUES (38, 'science-research', 2);
INSERT INTO assessment_option_weights (option_id, category_slug, weight) VALUES (39, 'agriculture', 2);
INSERT INTO assessment_option_weights (option_id, category_slug, weight) VALUES (40, 'medical-healthcare', 2);
INSERT INTO assessment_option_weights (option_id, category_slug, weight) VALUES (40, 'science-research', 1);

INSERT INTO assessment_option_weights (option_id, category_slug, weight) VALUES (41, 'design-creative', 2);
INSERT INTO assessment_option_weights (option_id, category_slug, weight) VALUES (42, 'media-communication', 2);
INSERT INTO assessment_option_weights (option_id, category_slug, weight) VALUES (43, 'media-communication', 2);
INSERT INTO assessment_option_weights (option_id, category_slug, weight) VALUES (43, 'design-creative', 1);
INSERT INTO assessment_option_weights (option_id, category_slug, weight) VALUES (44, 'arts-humanities', 2);

INSERT INTO assessment_option_weights (option_id, category_slug, weight) VALUES (45, 'commerce-finance', 2);
INSERT INTO assessment_option_weights (option_id, category_slug, weight) VALUES (46, 'banking-insurance', 2);
INSERT INTO assessment_option_weights (option_id, category_slug, weight) VALUES (47, 'management-business', 2);
INSERT INTO assessment_option_weights (option_id, category_slug, weight) VALUES (48, 'entrepreneurship', 2);

INSERT INTO assessment_option_weights (option_id, category_slug, weight) VALUES (49, 'government-civil-services', 2);
INSERT INTO assessment_option_weights (option_id, category_slug, weight) VALUES (50, 'defence', 2);
INSERT INTO assessment_option_weights (option_id, category_slug, weight) VALUES (51, 'law', 2);
INSERT INTO assessment_option_weights (option_id, category_slug, weight) VALUES (52, 'education-teaching', 2);

INSERT INTO assessment_option_weights (option_id, category_slug, weight) VALUES (53, 'skilled-trades', 2);
INSERT INTO assessment_option_weights (option_id, category_slug, weight) VALUES (54, 'sports-fitness', 2);
INSERT INTO assessment_option_weights (option_id, category_slug, weight) VALUES (55, 'hospitality-tourism', 2);
INSERT INTO assessment_option_weights (option_id, category_slug, weight) VALUES (56, 'skilled-trades', 1);
INSERT INTO assessment_option_weights (option_id, category_slug, weight) VALUES (56, 'agriculture', 1);
