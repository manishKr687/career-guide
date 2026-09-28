package com.careerguide.api.entity;

/**
 * Composes the display title of a (degree, subject) pair.
 *
 * <p>Since V105 no {@code degrees} row stores a combined title -- "B.A.
 * (Psychology)" is a B.A. plus the Psychology subject, joined at render time.
 * That join is a single rule and lives here, because the alternative is each
 * page inventing its own and the four of them drifting apart.
 *
 * <p>The rule is not one format. English uses parentheses for bachelor's and
 * master's but "in" for doctorates:
 *
 * <pre>
 *   Undergraduate / Postgraduate / Diploma / Certificate
 *       B.A.  + Psychology  ->  "B.A. (Psychology)"
 *   Doctoral
 *       PhD   + Psychology  ->  "PhD in Psychology"
 * </pre>
 *
 * <p>This matters because the rows deleted in V102/V105 were titled exactly
 * that way by hand -- "B.A. (Psychology)" but "PhD in Psychology" -- and
 * composing them uniformly would have silently reworded 15 doctorates.
 *
 * <p>A null or blank subject yields the degree title unchanged, which is the
 * correct output for fused qualifications (MBBS) and for rows whose subject
 * has not been filled in yet.
 */
public final class QualificationTitle {

    private QualificationTitle() {
    }

    public static String compose(Degree degree, Subject subject) {
        if (degree == null) {
            return null;
        }
        if (subject == null) {
            return degree.getTitle();
        }
        return compose(degree.getTitle(), degree.getLevel(), subject.getTitle());
    }

    /**
     * String form, for callers that hold titles rather than entities.
     */
    public static String compose(String degreeTitle, String degreeLevel, String subjectTitle) {
        if (subjectTitle == null || subjectTitle.isBlank()) {
            return degreeTitle;
        }
        return "Doctoral".equals(degreeLevel)
                ? degreeTitle + " in " + subjectTitle
                : degreeTitle + " (" + subjectTitle + ")";
    }
}
