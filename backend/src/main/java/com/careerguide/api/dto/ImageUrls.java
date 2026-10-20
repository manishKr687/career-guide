package com.careerguide.api.dto;

/**
 * The card-thumbnail URL format, defined once for CareerUpsertRequest and
 * CollegeUpsertRequest -- and mirrored by the CHECK constraints in V147, which
 * cover writes that bypass the API.
 *
 * <p>Two shapes are accepted, plus the empty string:
 *
 * <ul>
 *   <li>a path the site serves itself, such as {@code /thumbnails/careers/law.webp}
 *       for a file under the frontend's {@code public/} folder;</li>
 *   <li>an {@code https://} URL;</li>
 *   <li>{@code ""}, meaning no image. The admin form posts a cleared text
 *       field as an empty string, so refusing it would make every career or
 *       college save without an image fail. The services store it as null,
 *       and V147's CHECK still refuses an empty string in the column.</li>
 * </ul>
 *
 * <p>Not {@code http://}: browsers block plain-http images on an https page,
 * so the card would show a broken image. Not {@code //host/...} either: it
 * looks like a site path but browsers read it as a link to another host, which
 * is why a site path may not start with two slashes. And nothing else an {@code <img src>}
 * could be abused with -- {@code javascript:}, {@code data:}, or a value that
 * breaks out of the attribute with a quote or angle bracket.
 *
 * <p>Possessive quantifiers for the same reason as {@link Slugs#PATTERN}: Bean
 * Validation does not run {@code @Size} first, so the pattern has to be safe on
 * an arbitrarily long input by itself. {@code ImageUrlsTest} pins both what is
 * accepted and what is refused.
 */
public final class ImageUrls {

    public static final String PATTERN = "^(?:|/(?!/)[A-Za-z0-9._~/-]++|https://[^\\s\"'<>]++)$";

    public static final int MAX_LENGTH = 500;

    private ImageUrls() {
    }
}
