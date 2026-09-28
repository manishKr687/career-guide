package com.careerguide.api.dto;

import java.util.List;

/** Added in V29 -- see Stream.java and the Data Model Roadmap doc. */
public record StreamDto(
        String slug,
        String name,
        String description,
        List<String> stageSlugs,
        // The careers this stream is the normal route into (V92). Sorted by
        // career title; empty is not expected -- the migration asserts no
        // stream leads nowhere.
        List<String> careerSlugs,
        // Subject combinations within this stream (V97) -- PCM/PCB/PCMB for
        // Science. EMPTY for Commerce, Arts & Humanities and Vocational,
        // which have no standard named combinations; callers must treat an
        // empty list as normal and fall back to careerSlugs.
        List<StreamCombinationDto> combinations
) {
}
