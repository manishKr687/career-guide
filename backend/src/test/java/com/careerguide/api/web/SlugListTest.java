package com.careerguide.api.web;

import org.junit.jupiter.api.Test;

import java.util.stream.IntStream;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

/**
 * Tests for {@link SlugList}, which parses the {@code ?slugs=a,b,c} parameter
 * the list endpoints accept.
 *
 * <p>Small class, but it decides the behaviour of an unauthenticated parameter on
 * ten endpoints, and two of its rules are easy to undo by accident:
 *
 * <ul>
 *   <li><b>Blank is rejected, not treated as "everything".</b> The controllers
 *       distinguish an absent parameter from a present-but-empty one, so
 *       {@code ?slugs=} reaches here and gets a 400. The first version of the
 *       controllers used {@code isBlank()} and returned all 413 skills for
 *       {@code ?slugs=} -- a client building the parameter from an empty array
 *       would have asked for nothing and received the whole table.</li>
 *   <li><b>Order is preserved.</b> The frontend restores its own ordering from
 *       the slugs it sent, so a parser that sorted or used a plain HashSet would
 *       scramble lists an admin arranged deliberately.</li>
 * </ul>
 */
class SlugListTest {

    @Test
    void parsesACommaSeparatedList() {
        assertThat(SlugList.parse("python,sql,java")).containsExactly("python", "sql", "java");
    }

    @Test
    void preservesTheOrderGiven() {
        // Not alphabetical, deliberately: the caller's order is meaningful.
        assertThat(SlugList.parse("sql,java,python")).containsExactly("sql", "java", "python");
    }

    @Test
    void trimsWhitespaceAroundEntries() {
        assertThat(SlugList.parse(" python , sql ,java ")).containsExactly("python", "sql", "java");
    }

    @Test
    void dropsDuplicatesKeepingTheFirstPosition() {
        // The caller builds this by concatenating relations, so a repeat is
        // ordinary input rather than an error worth a 400.
        assertThat(SlugList.parse("python,sql,python,java")).containsExactly("python", "sql", "java");
    }

    @Test
    void ignoresEmptyEntriesFromStrayCommas() {
        assertThat(SlugList.parse("python,,sql,")).containsExactly("python", "sql");
    }

    @Test
    void acceptsASingleSlug() {
        assertThat(SlugList.parse("python")).containsExactly("python");
    }

    @Test
    void rejectsNullAndBlankRatherThanMeaningEverything() {
        // The regression this guards is described in the class javadoc: returning
        // the whole table for "I asked for nothing" is the dangerous reading.
        for (String bad : new String[]{null, "", "   ", ",", ",,", " , , "}) {
            assertThatThrownBy(() -> SlugList.parse(bad))
                    .as("parse(%s) must be rejected", bad == null ? "null" : "\"" + bad + "\"")
                    .isInstanceOf(IllegalArgumentException.class);
        }
    }

    @Test
    void acceptsExactlyTheMaximum() {
        String atLimit = IntStream.range(0, SlugList.MAX)
                .mapToObj(i -> "slug-" + i)
                .reduce((a, b) -> a + "," + b)
                .orElseThrow();

        assertThat(SlugList.parse(atLimit)).hasSize(SlugList.MAX);
    }

    @Test
    void rejectsOneOverTheMaximum() {
        // The cap is what stops this being a way to ask for the entire database
        // in one unauthenticated request.
        String overLimit = IntStream.range(0, SlugList.MAX + 1)
                .mapToObj(i -> "slug-" + i)
                .reduce((a, b) -> a + "," + b)
                .orElseThrow();

        assertThatThrownBy(() -> SlugList.parse(overLimit))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining(String.valueOf(SlugList.MAX));
    }

    @Test
    void countsDistinctSlugsAgainstTheCapRatherThanRawEntries() {
        // 400 entries, all the same slug, is one slug and must be allowed --
        // otherwise a caller with a duplicate-heavy relation list gets a 400 for
        // a request that asks for almost nothing.
        String manyDuplicates = IntStream.range(0, 400)
                .mapToObj(i -> "python")
                .reduce((a, b) -> a + "," + b)
                .orElseThrow();

        assertThat(SlugList.parse(manyDuplicates)).containsExactly("python");
    }

    @Test
    void theReturnedListIsImmutable() {
        // Services pass it straight to findAllById; nothing should be able to
        // mutate a parsed request's slug list afterwards.
        assertThatThrownBy(() -> SlugList.parse("python,sql").add("java"))
                .isInstanceOf(UnsupportedOperationException.class);
    }
}
