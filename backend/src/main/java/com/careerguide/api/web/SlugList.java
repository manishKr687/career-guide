package com.careerguide.api.web;

import java.util.Arrays;
import java.util.LinkedHashSet;
import java.util.List;

/**
 * Parses the {@code ?slugs=a,b,c} parameter the list endpoints accept.
 *
 * <h2>Why that parameter exists</h2>
 *
 * The frontend resolves relations by slug: a career page needs the full records
 * for its skills, job roles, industries, colleges, specializations, exams and
 * degrees. {@code fetchManyBySlug} used to do that one HTTP request at a time.
 * For {@code computer-science-and-engineering} that is <b>159 requests and 159
 * database queries to render one page</b> — 40 skills, 54 colleges, 24 job
 * roles, 16 specializations, 14 industries, 6 exams, 5 degrees.
 *
 * <p>Invisible on a developer machine, where the API answers in microseconds and
 * the whole page still rendered in 0.29s. Not invisible anywhere else: 159
 * round trips across a network is seconds, and 159 queries per page view is load
 * the database should never have been asked for.
 *
 * <p>With this parameter the same page costs seven requests, each returning only
 * the rows asked for.
 *
 * <h2>Bounded on purpose</h2>
 *
 * {@link #MAX} caps how many slugs one request may name. Without a cap this is a
 * way to ask the database for everything in one unauthenticated call, with a URL
 * long enough to be its own problem. 200 is comfortably above the worst real
 * case (54) and far below anything abusive.
 */
public final class SlugList {

    /** Most slugs a single request may name. */
    public static final int MAX = 200;

    /**
     * Splits the parameter into distinct, non-blank slugs, preserving the order
     * given.
     *
     * <p>Duplicates are dropped rather than rejected: the caller builds this
     * list by concatenating relations, so a slug appearing twice is ordinary and
     * not worth a 400. Order is preserved because the client relies on it to
     * restore its own ordering without a second sort.
     *
     * @throws IllegalArgumentException if blank, or above {@link #MAX}, which
     * {@code GlobalExceptionHandler} turns into a 400.
     */
    public static List<String> parse(String slugs) {
        if (slugs == null || slugs.isBlank()) {
            throw new IllegalArgumentException("slugs must not be blank");
        }
        LinkedHashSet<String> distinct = new LinkedHashSet<>(
                Arrays.stream(slugs.split(","))
                        .map(String::trim)
                        .filter(s -> !s.isEmpty())
                        .toList());
        if (distinct.isEmpty()) {
            throw new IllegalArgumentException("slugs must name at least one slug");
        }
        if (distinct.size() > MAX) {
            throw new IllegalArgumentException(
                    "slugs names " + distinct.size() + " slugs; at most " + MAX + " are allowed per request");
        }
        return List.copyOf(distinct);
    }

    private SlugList() {
    }
}
