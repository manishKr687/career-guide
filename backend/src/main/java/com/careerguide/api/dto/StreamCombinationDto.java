package com.careerguide.api.dto;

import java.util.List;

/**
 * A subject combination within a stream -- PCM, PCB, PCMB. Added in V97.
 *
 * <p>Nested inside {@link StreamDto} rather than fetched separately: a
 * combination is meaningless without its stream, and the four streams plus
 * three combinations are small enough that splitting them across two
 * round-trips would cost more than it saves.
 *
 * <p>{@code careerSlugs} is a subset of its stream's own list. A PCM student
 * sees 23 of Science's 29; the six they do not see are Biology-gated.
 */
public record StreamCombinationDto(
        String slug,
        String streamSlug,
        String name,
        String shortName,
        String description,
        List<String> careerSlugs
) {
}
