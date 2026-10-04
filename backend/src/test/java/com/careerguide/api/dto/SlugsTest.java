package com.careerguide.api.dto;

import org.junit.jupiter.api.Test;

import java.util.regex.Pattern;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;

/**
 * Tests {@link Slugs#PATTERN}.
 *
 * <p>This pattern validates the primary key of every catalogue row, on fourteen
 * admin endpoints. It was changed from {@code ^[a-z0-9]+(-[a-z0-9]+)*$} to a
 * possessive form to remove the nested quantifier Sonar flagged
 * ({@code java:S5998}), and the risk in that change is subtle: possessive
 * quantifiers can silently alter which strings match, which here would mean
 * either rejecting slugs that already exist in the database or admitting
 * malformed ones.
 *
 * <p>So the first test does not check the new pattern against hand-written
 * expectations. It checks it against <em>the old pattern</em>, case by case, so
 * that "the language is unchanged" is verified rather than asserted.
 */
class SlugsTest {

    /** Exactly what was in all fourteen DTOs before the change. */
    private static final Pattern ORIGINAL = Pattern.compile("^[a-z0-9]+(-[a-z0-9]+)*$");

    private static final Pattern CURRENT = Pattern.compile(Slugs.PATTERN);

    private static final String[] CASES = {
            // Real slugs from the catalogue.
            "computer-science-and-engineering", "neet-ug", "iit-bombay", "jee-main",
            "artificial-intelligence-and-machine-learning", "b-tech", "cat", "a", "0",
            "careerguide-2026", "ui-ux-design", "cad-cam",
            // Must be rejected.
            "", "-", "--", "-leading", "trailing-", "double--hyphen", "Upper", "UPPER",
            "with space", "with_underscore", "with.dot", "with/slash", "café",
            "देव", "emoji-🔐", "tab\there", "new\nline", " leading-space",
            "trailing-space ", "a--b", "a-", "-a", "a b", "a.b", "a/b",
    };

    @Test
    void theNewPatternMatchesExactlyTheSameStringsAsTheOldOne() {
        for (String candidate : CASES) {
            assertThat(CURRENT.matcher(candidate).matches())
                    .as("\"%s\" must match the possessive pattern iff it matched the original",
                            candidate.replace("\n", "\\n").replace("\t", "\\t"))
                    .isEqualTo(ORIGINAL.matcher(candidate).matches());
        }
    }

    @Test
    void acceptsTheSlugShapesTheCatalogueActuallyUses() {
        // Stated independently of the old pattern, so a future change to both
        // cannot quietly redefine what a slug is.
        assertThat(CURRENT.matcher("computer-science-and-engineering").matches()).isTrue();
        assertThat(CURRENT.matcher("neet-ug").matches()).isTrue();
        assertThat(CURRENT.matcher("b-tech").matches()).isTrue();
        assertThat(CURRENT.matcher("cat").matches()).isTrue();
        assertThat(CURRENT.matcher("careerguide-2026").matches()).isTrue();
    }

    @Test
    void rejectsTheShapesThatWouldBreakAUrlOrAForeignKey() {
        for (String bad : new String[]{"", "-", "Upper", "a--b", "a-", "-a", "a b", "a/b", "a.b"}) {
            assertThat(CURRENT.matcher(bad).matches())
                    .as("\"%s\" must be rejected", bad)
                    .isFalse();
        }
    }

    @Test
    void doesNotOverflowTheStackOnALongAdversarialInput() {
        // The reason for the change. The original pattern nests + inside *, and
        // Java implements that group loop recursively, so a long input of
        // repeating segments recurses until the stack gives out -- before any
        // @Size constraint rejects it, since Bean Validation does not order
        // constraints.
        //
        // 64 KB is the ceiling RequestSizeLimitFilter now enforces on a request
        // body, so this is the worst input that can actually arrive.
        String adversarial = "a-".repeat(32_000) + "a";
        assertThat(adversarial.length()).isGreaterThan(64_000);

        assertThatCode(() -> CURRENT.matcher(adversarial).matches())
                .doesNotThrowAnyException();
        // It is a valid slug by shape, just an absurd one -- length is @Size's job.
        assertThat(CURRENT.matcher(adversarial).matches()).isTrue();
    }

    @Test
    void doesNotOverflowOnALongNonMatchingInput() {
        // The harder case: a near-miss forces the engine to explore before
        // failing, which is where a backtracking pattern does its worst.
        String adversarial = "a-".repeat(32_000) + "A";

        assertThatCode(() -> CURRENT.matcher(adversarial).matches())
                .doesNotThrowAnyException();
        assertThat(CURRENT.matcher(adversarial).matches()).isFalse();
    }

    @Test
    void theSharedMessageIsUsedRatherThanFourteenCopies() {
        // The message is part of the API contract -- it is what an admin sees on
        // a rejected form. Pinned so the fourteen DTOs cannot drift apart again.
        assertThat(Slugs.MESSAGE).isEqualTo("must be lowercase letters, numbers and hyphens only");
    }
}
