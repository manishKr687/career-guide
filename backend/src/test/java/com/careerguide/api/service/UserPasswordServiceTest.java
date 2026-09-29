package com.careerguide.api.service;

import org.junit.jupiter.api.Test;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import java.nio.charset.StandardCharsets;
import java.util.Base64;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;

/**
 * Tests for {@link UserPasswordService}, which had none.
 *
 * <p>This is the class where a silent bug is worst. Everything else in this
 * codebase fails visibly -- a wrong salary band is wrong on the page. Here, a
 * {@code matches} that returned true too readily would let anyone into any
 * account and nothing on the site would look different. So the tests below care
 * less about the happy path (one test) than about the ways verification could
 * wrongly succeed, and about the malformed input that must be rejected rather
 * than thrown on: {@code matches} is called with whatever is in the database
 * column, and an exception there is a 500 on the login endpoint.
 *
 * <p>No mocks and no Spring context -- the service takes no collaborators.
 *
 * <p>These tests are deliberately slower than the rest of the suite. PBKDF2 at
 * 210,000 iterations costs roughly 100ms per call by design, and that cost is
 * the security property, so it is not mocked away.
 */
class UserPasswordServiceTest {

    private final UserPasswordService service = new UserPasswordService();

    @Test
    void hashThenMatchesAcceptsTheCorrectPassword() {
        String hash = service.hash("correct horse battery staple");

        assertThat(service.matches("correct horse battery staple", hash)).isTrue();
    }

    @Test
    void matchesRejectsAWrongPassword() {
        String hash = service.hash("correct horse battery staple");

        assertThat(service.matches("wrong horse battery staple", hash)).isFalse();
    }

    @Test
    void matchesIsCaseSensitive() {
        String hash = service.hash("Password1");

        assertThat(service.matches("password1", hash)).isFalse();
    }

    @Test
    void matchesDoesNotTrimWhitespace() {
        // A password store that quietly trims accepts a different secret than
        // the one the user set.
        String hash = service.hash("secret");

        assertThat(service.matches("secret ", hash)).isFalse();
        assertThat(service.matches(" secret", hash)).isFalse();
    }

    @Test
    void theSamePasswordHashesDifferentlyEachTime() {
        // A random salt per hash is what stops two users with the same password
        // having the same stored value, and stops a precomputed table working.
        String first = service.hash("same password");
        String second = service.hash("same password");

        assertThat(first).isNotEqualTo(second);
        assertThat(service.matches("same password", first)).isTrue();
        assertThat(service.matches("same password", second)).isTrue();
    }

    @Test
    void hashIsSelfDescribingWithTheCurrentIterationCount() {
        // The stored format is the contract that lets the iteration count be
        // raised later without invalidating existing passwords. If this shape
        // changes, every row already in the database stops verifying.
        String hash = service.hash("whatever");
        String[] parts = hash.split(":");

        assertThat(parts).hasSize(4);
        assertThat(parts[0]).isEqualTo("pbkdf2");
        assertThat(Integer.parseInt(parts[1])).isEqualTo(210_000);
        assertThat(Base64.getUrlDecoder().decode(parts[2])).hasSize(16);   // salt
        assertThat(Base64.getUrlDecoder().decode(parts[3])).hasSize(32);   // 256-bit key
    }

    @Test
    void matchesHonoursTheStoredIterationCountRatherThanTheCurrentOne() {
        // The point of storing the count is that a password hashed under an
        // older, lower count still verifies after the constant is raised. That
        // claim is untestable through hash(), which always uses the current
        // constant, so the old-format value is built here with the same
        // algorithm and a deliberately different count.
        String legacyHash = pbkdf2Hash("my password", "0123456789abcdef".getBytes(StandardCharsets.UTF_8), 1_000);

        assertThat(service.matches("my password", legacyHash)).isTrue();
        assertThat(service.matches("not my password", legacyHash)).isFalse();
    }

    @Test
    void matchesRejectsAHashWhoseIterationCountHasBeenAltered() {
        // Proves the count is actually fed into the derivation rather than
        // parsed and ignored -- if it were ignored, this would still match.
        String hash = service.hash("my password");
        String[] parts = hash.split(":");
        String tampered = parts[0] + ":" + 209_999 + ":" + parts[2] + ":" + parts[3];

        assertThat(service.matches("my password", tampered)).isFalse();
    }

    @Test
    void matchesRejectsAHashWithATamperedSalt() {
        String hash = service.hash("my password");
        String[] parts = hash.split(":");
        byte[] salt = Base64.getUrlDecoder().decode(parts[2]);
        salt[0] ^= 0x01;
        String tampered = parts[0] + ":" + parts[1] + ":"
                + Base64.getUrlEncoder().withoutPadding().encodeToString(salt) + ":" + parts[3];

        assertThat(service.matches("my password", tampered)).isFalse();
    }

    @Test
    void matchesReturnsFalseForMalformedStoredValuesRatherThanThrowing() {
        // matches() is handed whatever sits in users.password_hash. A throw here
        // is a 500 on /api/auth/login instead of a clean "invalid credentials",
        // and it tells an attacker they found something interesting.
        String[] malformed = {
                "",
                "not-a-hash",
                "pbkdf2",                                  // no separators
                "pbkdf2:210000:onlythreeparts",            // too few parts
                "pbkdf2:210000:c2FsdA:aGFzaA:extra",       // too many parts
                "bcrypt:210000:c2FsdA:aGFzaA",             // wrong algorithm label
                "pbkdf2:notanumber:c2FsdA:aGFzaA",         // unparseable iterations
                "pbkdf2:210000:!!!notbase64!!!:aGFzaA",    // salt is not base64
                "pbkdf2:210000:c2FsdA:!!!notbase64!!!",    // hash is not base64
                ":::",
        };

        for (String stored : malformed) {
            assertThatCode(() -> service.matches("any password", stored))
                    .as("matches(..., \"%s\") must not throw", stored)
                    .doesNotThrowAnyException();
            assertThat(service.matches("any password", stored))
                    .as("matches(..., \"%s\") must be false", stored)
                    .isFalse();
        }
    }

    @Test
    void matchesRejectsAnEmptyStoredHashComponentInsteadOfMatchingEverything() {
        // The nightmare case: a row whose hash field is empty must not verify
        // against an empty password.
        assertThat(service.matches("", "pbkdf2:210000::")).isFalse();
        assertThat(service.matches("anything", "pbkdf2:210000::")).isFalse();
    }

    @Test
    void handlesAnEmptyPassword() {
        // Rejecting empty passwords is the registration endpoint's job, not
        // this class's; what matters here is that it hashes and verifies
        // consistently rather than behaving specially.
        String hash = service.hash("");

        assertThat(service.matches("", hash)).isTrue();
        assertThat(service.matches("x", hash)).isFalse();
    }

    @Test
    void handlesUnicodeAndLongPasswords() {
        String unicode = "paß·wörd·पासवर्ड·密码·🔐";
        String longPassword = "a".repeat(4096);

        assertThat(service.matches(unicode, service.hash(unicode))).isTrue();
        assertThat(service.matches(longPassword, service.hash(longPassword))).isTrue();
        assertThat(service.matches(longPassword + "a", service.hash(longPassword))).isFalse();
    }

    /** Builds a stored-format hash directly, so a non-current iteration count can be tested. */
    private static String pbkdf2Hash(String password, byte[] salt, int iterations) {
        try {
            PBEKeySpec spec = new PBEKeySpec(password.toCharArray(), salt, iterations, 256);
            byte[] key = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256").generateSecret(spec).getEncoded();
            Base64.Encoder encoder = Base64.getUrlEncoder().withoutPadding();
            return "pbkdf2:" + iterations + ":" + encoder.encodeToString(salt) + ":" + encoder.encodeToString(key);
        } catch (java.security.GeneralSecurityException e) {
            throw new IllegalStateException(e);
        }
    }
}
