package com.careerguide.api.dto;

/**
 * The slug format, defined once.
 *
 * <p>Fourteen upsert DTOs carried an identical copy of this regex. That is not
 * only duplication: SonarQube reported each one separately as a bug
 * ({@code java:S5998}), so one regex produced fourteen findings, and fixing it
 * meant fourteen edits that had to agree.
 *
 * <h2>Why the quantifiers are possessive</h2>
 *
 * The original was {@code ^[a-z0-9]+(-[a-z0-9]+)*$} — a {@code +} nested inside
 * a {@code *}. Java's regex engine implements that group loop recursively, so a
 * long enough input recurses deep enough to throw {@code StackOverflowError}
 * before any length check rejects it. Bean Validation gives no ordering
 * guarantee between constraints, so the neighbouring {@code @Size(max = 64)}
 * does <em>not</em> run first and does not protect this.
 *
 * <p>Possessive quantifiers ({@code ++}, {@code *+}) never give back what they
 * matched, so there is no backtracking and no recursion to overflow. The
 * language matched is unchanged, which {@code SlugsTest} verifies case by case
 * rather than taking on trust:
 *
 * <ul>
 *   <li>{@code [a-z0-9]++} takes a run of slug characters and stops at the
 *       hyphen it cannot consume.</li>
 *   <li>{@code (?:-[a-z0-9]++)*+} takes each {@code -segment} that follows.</li>
 *   <li>A trailing hyphen or a double hyphen still fails, because the group
 *       needs at least one slug character after each hyphen and {@code $} then
 *       has characters left over.</li>
 * </ul>
 *
 * <p>Non-capturing {@code (?:...)} as well, since nothing reads the group.
 *
 * <p>The in-practice severity was low — every endpoint using this sits behind an
 * admin token, and {@code RequestSizeLimitFilter} now caps a body at 64 KB. It
 * is fixed because the fix is one line in one place and removes a whole class of
 * failure rather than making it unlikely.
 */
public final class Slugs {

    /**
     * Lowercase alphanumeric segments joined by single hyphens: {@code
     * computer-science}, {@code neet-ug}, {@code iit-bombay}. No leading or
     * trailing hyphen, no consecutive hyphens, no uppercase.
     */
    public static final String PATTERN = "^[a-z0-9]++(?:-[a-z0-9]++)*+$";

    /** The message every slug field shares, so they cannot drift apart. */
    public static final String MESSAGE = "must be lowercase letters, numbers and hyphens only";

    private Slugs() {
    }
}
