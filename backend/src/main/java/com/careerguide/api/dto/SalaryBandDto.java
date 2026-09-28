package com.careerguide.api.dto;

import java.math.BigDecimal;

/**
 * What a career pays at one experience level. Added in V110.
 *
 * <p>Numbers, with the display string derived -- the V107 rule. {@code maxLpa}
 * is null on the top band and means open-ended ("₹40L+ / year").
 *
 * <p>Ships empty for all 42 careers; see {@code CareerSalaryBand}'s javadoc
 * for why the figures were not generated.
 */
public record SalaryBandDto(
        String band,
        BigDecimal minLpa,
        BigDecimal maxLpa,
        String label
) {
}
