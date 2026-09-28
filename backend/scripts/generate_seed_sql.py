#!/usr/bin/env python3
"""
Generates Flyway seed migrations (V2..V9) from the JSON exported out of the
Next.js frontend's data files (backend/seed-json/*.json).

Run from backend/: python3 scripts/generate_seed_sql.py
"""
import json
import os

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
JSON_DIR = os.path.join(BASE, "seed-json")
OUT_DIR = os.path.join(BASE, "src", "main", "resources", "db", "migration")


def load(name):
    with open(os.path.join(JSON_DIR, f"{name}.json")) as f:
        return json.load(f)


def s(value):
    """SQL string literal with proper single-quote escaping."""
    return "'" + str(value).replace("'", "''") + "'"


def arr(values):
    """Postgres text[] array literal, e.g. ARRAY['a','b']."""
    if not values:
        return "ARRAY[]::text[]"
    return "ARRAY[" + ",".join(s(v) for v in values) + "]"


def write(filename, statements):
    path = os.path.join(OUT_DIR, filename)
    with open(path, "w") as f:
        f.write("\n".join(statements) + "\n")
    print(f"wrote {filename} ({len(statements)} statements)")


def gen_categories():
    categories = load("categories")
    stmts = []
    for c in categories:
        stmts.append(
            f"INSERT INTO categories (slug, name, icon, color) VALUES "
            f"({s(c['slug'])}, {s(c['name'])}, {s(c['icon'])}, {s(c['color'])});"
        )
    write("V2__seed_categories.sql", stmts)


def gen_stages():
    stages = load("stages")
    stmts = []
    for i, st in enumerate(stages):
        stmts.append(
            "INSERT INTO stages (slug, name, tagline, description, badge_soft, badge_solid, icon, highlights, sort_order) VALUES "
            f"({s(st['slug'])}, {s(st['name'])}, {s(st['tagline'])}, {s(st['description'])}, "
            f"{s(st['badgeSoft'])}, {s(st['badgeSolid'])}, {s(st['icon'])}, {arr(st['highlights'])}, {i});"
        )
    write("V3__seed_stages.sql", stmts)


def gen_careers():
    careers = load("careers")
    # sort_order tracks each career's index within its own category, in the
    # same order careers.ts lists them — this is what lets the assessment's
    # "recommended careers" pick reproduce the frontend's array-order pick
    # instead of an arbitrary DB order.
    per_category_index = {}
    stmts = []
    for c in careers:
        idx = per_category_index.get(c["categorySlug"], 0)
        per_category_index[c["categorySlug"]] = idx + 1
        stmts.append(
            "INSERT INTO careers (slug, title, category_slug, tagline, demand, education, skills, "
            "typical_work, salary_range, growth_path, icon, description, sort_order) VALUES "
            f"({s(c['slug'])}, {s(c['title'])}, {s(c['categorySlug'])}, {s(c['tagline'])}, {s(c['demand'])}, "
            f"{s(c['education'])}, {arr(c['skills'])}, {s(c['typicalWork'])}, {s(c['salaryRange'])}, "
            f"{arr(c['growthPath'])}, {s(c['icon'])}, {s(c['description'])}, {idx});"
        )
    write("V4__seed_careers.sql", stmts)


def gen_courses():
    courses = load("courses")
    stmts = []
    for c in courses:
        stmts.append(
            "INSERT INTO courses (slug, name, level, duration, description, eligibility, icon) VALUES "
            f"({s(c['slug'])}, {s(c['name'])}, {s(c['level'])}, {s(c['duration'])}, "
            f"{s(c['description'])}, {s(c['eligibility'])}, {s(c['icon'])});"
        )
    write("V5__seed_courses.sql", stmts)


def gen_exams():
    exams = load("exams")
    stmts = []
    for e in exams:
        stmts.append(
            "INSERT INTO exams (slug, name, full_name, category, conducted_by, frequency, description, icon) VALUES "
            f"({s(e['slug'])}, {s(e['name'])}, {s(e['fullName'])}, {s(e['category'])}, "
            f"{s(e['conductedBy'])}, {s(e['frequency'])}, {s(e['description'])}, {s(e['icon'])});"
        )
    write("V6__seed_exams.sql", stmts)


def gen_colleges():
    colleges = load("colleges")
    stmts = []
    for c in colleges:
        stmts.append(
            "INSERT INTO colleges (slug, name, location, type, established, tags, description) VALUES "
            f"({s(c['slug'])}, {s(c['name'])}, {s(c['location'])}, {s(c['type'])}, "
            f"{int(c['established'])}, {arr(c['tags'])}, {s(c['description'])});"
        )
    write("V7__seed_colleges.sql", stmts)


def gen_relations():
    careers = load("careers")
    courses = load("courses")
    exams = load("exams")
    colleges = load("colleges")
    stages = load("stages")

    stmts = []

    def link(table, left_col, right_col, left_val, items):
        for i, right_val in enumerate(items):
            stmts.append(
                f"INSERT INTO {table} ({left_col}, {right_col}, sort_order) VALUES "
                f"({s(left_val)}, {s(right_val)}, {i}) ON CONFLICT DO NOTHING;"
            )

    for c in careers:
        link("career_courses", "career_slug", "course_slug", c["slug"], c["relatedCourseSlugs"])
        link("career_exams", "career_slug", "exam_slug", c["slug"], c["relatedExamSlugs"])
        link("career_stages", "career_slug", "stage_slug", c["slug"], c["stageSlugs"])

    for c in courses:
        link("course_careers", "course_slug", "career_slug", c["slug"], c["careerSlugs"])
        link("course_exams", "course_slug", "exam_slug", c["slug"], c["examSlugs"])

    for e in exams:
        link("exam_careers", "exam_slug", "career_slug", e["slug"], e["careerSlugs"])
        link("exam_courses", "exam_slug", "course_slug", e["slug"], e["courseSlugs"])

    for c in colleges:
        link("college_courses", "college_slug", "course_slug", c["slug"], c["courseSlugs"])
        link("college_exams", "college_slug", "exam_slug", c["slug"], c["examSlugs"])

    for st in stages:
        link("stage_careers", "stage_slug", "career_slug", st["slug"], st["relatedCareerSlugs"])
        link("stage_courses", "stage_slug", "course_slug", st["slug"], st["relatedCourseSlugs"])
        link("stage_exams", "stage_slug", "exam_slug", st["slug"], st["relatedExamSlugs"])

    write("V8__seed_relations.sql", stmts)


def gen_assessment():
    questions = load("assessment-questions")
    stmts = []
    # Use a session variable-free approach: rely on RETURNING + a temp mapping table
    # is overkill here; instead we insert options with deterministic ids by
    # pre-assigning ids ourselves so weights can reference them directly.
    option_id = 0
    weight_stmts = []
    for qi, q in enumerate(questions):
        stmts.append(
            f"INSERT INTO assessment_questions (id, question, sort_order) VALUES "
            f"({s(q['id'])}, {s(q['question'])}, {qi});"
        )
        for oi, opt in enumerate(q["options"]):
            option_id += 1
            stmts.append(
                "INSERT INTO assessment_options (id, question_id, option_key, label, sort_order) VALUES "
                f"({option_id}, {s(q['id'])}, {s(opt['id'])}, {s(opt['label'])}, {oi});"
            )
            for cat_slug, weight in opt["weights"].items():
                weight_stmts.append(
                    "INSERT INTO assessment_option_weights (option_id, category_slug, weight) VALUES "
                    f"({option_id}, {s(cat_slug)}, {int(weight)});"
                )
    stmts.append(f"SELECT setval(pg_get_serial_sequence('assessment_options','id'), {option_id});")
    stmts.extend(weight_stmts)
    write("V9__seed_assessment.sql", stmts)


if __name__ == "__main__":
    os.makedirs(OUT_DIR, exist_ok=True)
    gen_categories()
    gen_stages()
    gen_careers()
    gen_courses()
    gen_exams()
    gen_colleges()
    gen_relations()
    gen_assessment()
    print("Done.")
