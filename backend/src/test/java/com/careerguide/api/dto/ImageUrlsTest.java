package com.careerguide.api.dto;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.regex.Pattern;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

class ImageUrlsTest {

    private static final Pattern P = Pattern.compile(ImageUrls.PATTERN);

    @ParameterizedTest
    @ValueSource(strings = {
            "/thumbnails/careers/law.webp",
            "/thumbnails/colleges/iit-madras.jpg",
            "https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=640&q=80",
            "https://upload.wikimedia.org/wikipedia/commons/a/a1/IIT_Madras.jpg",
            "",   // a cleared admin field: means no image, stored as null
    })
    void acceptsSitePathsAndHttpsUrls(String url) {
        assertThat(P.matcher(url).matches()).as(url).isTrue();
    }

    @ParameterizedTest
    @ValueSource(strings = {
            "http://example.com/a.jpg",            // mixed content: blocked by browsers
            "javascript:alert(1)",
            "data:image/png;base64,iVBORw0KGgo=",
            "//evil.example/a.jpg",                // protocol-relative
            "thumbnails/careers/law.webp",         // relative, would resolve per page
            "/thumbnails/a b.webp",                // whitespace
            "https://x.example/a.jpg\" onerror=\"alert(1)", // breaks out of the attribute
            "https://x.example/<script>",
            "https://",
            "/",
            " ",
    })
    void refusesEverythingElse(String url) {
        assertThat(P.matcher(url).matches()).as(url).isFalse();
    }

    @Test
    void doesNotOverflowOnAVeryLongInput() {
        // Bean Validation gives no ordering guarantee, so @Size does not run
        // first; the pattern itself must cope with an arbitrarily long value.
        String huge = "/" + "a/".repeat(200_000) + "x";
        assertThat(P.matcher(huge).matches()).isTrue();
        assertThat(P.matcher(huge + " ").matches()).isFalse();
    }
}
