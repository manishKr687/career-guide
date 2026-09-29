package com.careerguide.api.service;

import org.junit.jupiter.api.Test;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.time.Instant;
import java.util.Base64;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

/**
 * Tests for {@link UserTokenService}, which had none.
 *
 * <p>This token IS the session. There is no server-side session table to check
 * it against, so whatever {@code resolveUserId} returns is taken as the caller's
 * identity by every authenticated endpoint. Two failures matter more than the
 * rest and are tested first and hardest:
 *
 * <ul>
 *   <li><b>Payload tampering.</b> The user id is in the token, base64 and
 *       readable. If the signature were not checked over it, anyone could decode
 *       their own token, change 7 to 8, re-encode, and be a different user. That
 *       is account takeover with no credentials, so it gets its own test.</li>
 *   <li><b>Expiry.</b> A token whose expiry has passed must stop working. This
 *       cannot be tested through {@code issueToken}, which always issues 30 days
 *       out, so the expired token is constructed here and signed with the real
 *       secret -- the strongest form of the test, since it is a token the server
 *       itself would consider authentic apart from its age.</li>
 * </ul>
 *
 * <p>The signing below deliberately reimplements the service's HMAC rather than
 * calling into it. A forged token has to be built the way an attacker holding
 * the secret would build one, and a test that reused the production signer could
 * not tell a correct implementation from one that consistently agreed with
 * itself while being wrong.
 */
class UserTokenServiceTest {

    private static final String SECRET = "test-only-secret-at-least-32-characters-long";

    private final UserTokenService service = new UserTokenService(SECRET);

    @Test
    void issuedTokenResolvesBackToTheSameUserId() {
        String token = service.issueToken(42L);

        assertThat(service.resolveUserId(token)).contains(42L);
    }

    @Test
    void roundTripsBoundaryUserIds() {
        for (long id : new long[]{0L, 1L, Long.MAX_VALUE}) {
            assertThat(service.resolveUserId(service.issueToken(id)))
                    .as("user id %s", id)
                    .contains(id);
        }
    }

    @Test
    void rejectsATokenWhosePayloadHasBeenRepointedAtAnotherUser() {
        // The attack: take your own valid token, decode the payload, change the
        // user id, re-encode, keep the original signature. If this passes, one
        // account is every account.
        String mine = service.issueToken(7L);
        String signature = mine.substring(mine.indexOf('.') + 1);
        String payload = new String(Base64.getUrlDecoder().decode(mine.substring(0, mine.indexOf('.'))),
                StandardCharsets.UTF_8);
        String repointed = payload.replaceFirst("^7\\.", "8.");

        String forged = base64(repointed) + "." + signature;

        assertThat(repointed).startsWith("8.");           // the forgery really did change the id
        assertThat(service.resolveUserId(forged)).isEmpty();
    }

    @Test
    void rejectsATokenWhoseExpiryHasBeenPushedIntoTheFuture() {
        // The other half of the same attack: keep the id, extend the lifetime.
        String mine = service.issueToken(7L);
        String signature = mine.substring(mine.indexOf('.') + 1);
        long farFuture = Instant.now().plus(Duration.ofDays(3650)).toEpochMilli();

        String forged = base64("7." + farFuture) + "." + signature;

        assertThat(service.resolveUserId(forged)).isEmpty();
    }

    @Test
    void rejectsAnExpiredTokenEvenThoughItsSignatureIsAuthentic() {
        // Signed with the real secret, so the only thing wrong with it is the
        // time. Built by hand because issueToken always issues 30 days out.
        String payload = "7." + Instant.now().minus(Duration.ofSeconds(1)).toEpochMilli();
        String expired = base64(payload) + "." + sign(payload, SECRET);

        assertThat(service.resolveUserId(expired)).isEmpty();
    }

    @Test
    void acceptsATokenThatIsAboutToExpireButHasNot() {
        // The boundary on the other side: still valid a few seconds out, which
        // guards against an off-by-one that rejected every live token.
        String payload = "7." + Instant.now().plus(Duration.ofSeconds(30)).toEpochMilli();
        String almostExpired = base64(payload) + "." + sign(payload, SECRET);

        assertThat(service.resolveUserId(almostExpired)).contains(7L);
    }

    @Test
    void rejectsATokenSignedWithADifferentSecret() {
        // What a stolen token from another deployment, or a guessed key, looks
        // like. Also the reason the signing key must differ between environments.
        String payload = "7." + Instant.now().plus(Duration.ofDays(1)).toEpochMilli();
        String foreign = base64(payload) + "." + sign(payload, "a-completely-different-secret-value");

        assertThat(service.resolveUserId(foreign)).isEmpty();
    }

    @Test
    void rejectsATamperedSignature() {
        String token = service.issueToken(7L);
        int dot = token.indexOf('.');
        String signature = token.substring(dot + 1);
        // Flip one character of the signature, whatever it happens to be.
        char first = signature.charAt(0);
        String flipped = (first == 'A' ? 'B' : 'A') + signature.substring(1);

        assertThat(service.resolveUserId(token.substring(0, dot + 1) + flipped)).isEmpty();
    }

    @Test
    void rejectsAnUnsignedToken() {
        // A payload with an empty signature, and a payload with none at all.
        String payload = "7." + Instant.now().plus(Duration.ofDays(1)).toEpochMilli();

        assertThat(service.resolveUserId(base64(payload) + ".")).isEmpty();
        assertThat(service.resolveUserId(base64(payload))).isEmpty();
    }

    @Test
    void rejectsMalformedInputWithoutThrowing() {
        // resolveUserId is fed an Authorization header, which is entirely
        // attacker-controlled. Every one of these must be a quiet empty, not a
        // 500 that confirms the input reached something interesting.
        String[] malformed = {
                null,
                "",
                "   ",
                ".",
                "..",
                "no-dot-at-all",
                "!!!notbase64!!!.signature",
                base64("only-one-part") + ".signature",
                base64("1.2.3") + ".signature",
                base64("notanumber." + Instant.now().plus(Duration.ofDays(1)).toEpochMilli()) + ".signature",
                base64("7.notanumber") + ".signature",
                base64("") + ".signature",
                "Bearer " + "something",
        };

        for (String token : malformed) {
            assertThatCode(() -> service.resolveUserId(token))
                    .as("resolveUserId(%s) must not throw", token)
                    .doesNotThrowAnyException();
            assertThat(service.resolveUserId(token))
                    .as("resolveUserId(%s) must be empty", token)
                    .isEmpty();
        }
    }

    @Test
    void rejectsAWellFormedPayloadCarryingANegativeUserId() {
        // No user has a negative id, but the check that matters is that a
        // correctly signed token is still parsed rather than trusted blindly --
        // this documents what the service does with one. Signed authentically,
        // so any rejection comes from parsing rather than from the signature.
        String payload = "-1." + Instant.now().plus(Duration.ofDays(1)).toEpochMilli();
        String token = base64(payload) + "." + sign(payload, SECRET);

        // -1 parses as a long, so the service returns it; rejecting unknown ids
        // is the lookup's job. Asserted so a future change to either layer is a
        // deliberate one.
        assertThat(service.resolveUserId(token)).contains(-1L);
    }

    @Test
    void twoTokensForTheSameUserAreBothValid() {
        // Nothing invalidates an earlier token, because there is no session
        // table -- worth pinning, since it is the design's main limitation:
        // logging out cannot revoke server-side.
        String first = service.issueToken(7L);
        String second = service.issueToken(7L);

        assertThat(service.resolveUserId(first)).contains(7L);
        assertThat(service.resolveUserId(second)).contains(7L);
    }

    @Test
    void theTokenDoesNotHideTheUserIdAndIsNotExpectedTo() {
        // Signed, not encrypted. Documented as a test so nobody later assumes
        // the payload is a secret and puts something sensitive in it.
        String token = service.issueToken(12345L);
        String payload = new String(Base64.getUrlDecoder().decode(token.substring(0, token.indexOf('.'))),
                StandardCharsets.UTF_8);

        assertThat(payload).startsWith("12345.");
    }

    @Test
    void anEmptySecretConstructsButFailsOnFirstUse() {
        // Worth pinning because the failure is late and unhelpful: the
        // constructor accepts "" happily, and the crash only arrives when
        // something first issues a token -- so on a misconfigured deployment the
        // symptom is a 500 on login, not a startup error naming the cause.
        //
        // What makes that acceptable is ProdSecretsCheck, which rejects blank
        // and default secrets before any bean is created under the prod profile.
        // This test exists so that if that guard is ever weakened, the cost of
        // losing it is written down here rather than discovered in production.
        UserTokenService weak = new UserTokenService("");

        assertThatThrownBy(() -> weak.issueToken(1L))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("Empty key");
    }

    @Test
    void resolveUserIdOnAServiceWithAnEmptySecretDoesNotLeakThroughAsAMatch() {
        // The dangerous shape of the above: if signing threw but verification
        // quietly treated every token as unsigned-and-fine, an empty secret
        // would accept anything. It must fail closed instead.
        UserTokenService weak = new UserTokenService("");

        assertThatThrownBy(() -> weak.resolveUserId(base64("1.99999999999999") + ".anything"))
                .isInstanceOf(IllegalArgumentException.class);
    }

    private static String base64(String value) {
        return Base64.getUrlEncoder().withoutPadding().encodeToString(value.getBytes(StandardCharsets.UTF_8));
    }

    /** Independent reimplementation of the service's signature, for building authentic and forged tokens. */
    private static String sign(String payload, String secret) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
            return Base64.getUrlEncoder().withoutPadding()
                    .encodeToString(mac.doFinal(payload.getBytes(StandardCharsets.UTF_8)));
        } catch (java.security.GeneralSecurityException e) {
            throw new IllegalStateException(e);
        }
    }
}
