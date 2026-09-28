package com.careerguide.api.entity;

import java.math.BigDecimal;

/**
 * Composes the display form of a salary range from its numbers.
 *
 * <p>Since V107 salary is stored as {@code salary_min_lpa} /
 * {@code salary_max_lpa} (lakhs per annum, NUMERIC). The string
 * "₹4L – ₹30L / year" is derived from those, not stored alongside them.
 *
 * <p>That direction matters. Before V107 the string WAS the storage, which
 * meant salary could not be filtered, sorted, aggregated or validated --
 * ordering by it put ₹10L before ₹4L, and a career's "₹4L" could not be
 * compared with a job role's "4 LPA" despite being the same figure. It also
 * meant nothing rejected malformed input: a bad round-trip once wrote
 * "â‚¹3L â€“ â‚¹15L / year" into a career and the column took it without
 * complaint. A NUMERIC column cannot hold that.
 *
 * <p>Keeping the composition here rather than in each page is the same
 * reasoning as {@link QualificationTitle}: one rule, one place, no drift.
 *
 * <p>Whole numbers render without a decimal part -- 4 is "₹4L", not "₹4.00L" --
 * while 2.5 keeps it, so the output matches how the figures are written.
 */
public final class SalaryRange {

    private SalaryRange() {
    }

    /**
     * Returns null when either bound is missing. Null means "not recorded",
     * which is different from zero, and 8 job roles are genuinely in that
     * state -- rendering "₹0L" for them would be a claim rather than a gap.
     */
    public static String compose(BigDecimal minLpa, BigDecimal maxLpa) {
        if (minLpa == null || maxLpa == null) {
            return null;
        }
        return "₹" + plain(minLpa) + "L – ₹" + plain(maxLpa) + "L / year";
    }

    /**
     * As {@link #compose} but tolerates an open-ended top: a null max renders
     * "₹40L+ / year" rather than nothing. Used by {@link CareerSalaryBand},
     * whose highest band has no ceiling -- picking one would put a number on
     * the page that nothing supports.
     */
    public static String composeOpenEnded(BigDecimal minLpa, BigDecimal maxLpa) {
        if (minLpa == null) {
            return null;
        }
        if (maxLpa == null) {
            return "₹" + plain(minLpa) + "L+ / year";
        }
        return compose(minLpa, maxLpa);
    }

    private static String plain(BigDecimal value) {
        return value.stripTrailingZeros().toPlainString();
    }
}
