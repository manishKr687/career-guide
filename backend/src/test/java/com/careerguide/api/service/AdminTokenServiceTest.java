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

/**
 * Tests for {@link AdminTokenService}, which had none.
 *
 * <p>A valid token here grants write access to the entire catalogue -- create,
 * update and delete on every admin endpoint. It is also the weaker of the two
 * token designs, because the payload is only an expiry: the token carries no
 * identity, so possession of the signing key is enough to mint a working
 * session offline, with no password and no request to the server. That is a
 * documented, accepted trade-off for a single shared admin, and
 * {@code keyHolderCanMintAValidTokenWithoutThePassword} pins it as a fact
 * rather than leaving it as a sentence in a javadoc -- if it ever stops being
 * true, that test failing is the intended signal.
 *
 * <p>The practical consequence is that {@code careerguide.admin.token-secret}
 * is as powerful as the admin password. {@code ProdSecretsCheck} refusing to
 * start on the published default is what keeps that from being a hole in this
 * public repository.
 *
 * <p>As in {@link UserTokenServiceTest}, the signing helper below reimplements
 * the HMAC rather than calling the service, so a forgery is built the way an
 * attacker would build one.
 */
class AdminTokenServiceTest {

    private static final String SECRET = "test-only-admin-secret-at-least-32-chars";

    private final AdminTokenService service = new AdminTokenService(SECRET);

    @Test
    void anIssuedTokenIsValid() {
        assertThat(service.isValid(service.issueToken())).isTrue();
    }

    @Test
    void rejectsAnExpiredTokenEvenThoughItsSignatureIsAuthentic() {
        // Signed with the real secret; only the time is wrong. Built by hand
        // because issueToken always issues 24 hours out.
        String payload = Long.toString(Instant.now().minus(Duration.ofSeconds(1)).toEpochMilli());

        assertThat(service.isValid(base64(payload) + "." + sign(payload, SECRET))).isFalse();
    }

    @Test
    void acceptsATokenThatHasNotQuiteExpired() {
        String payload = Long.toString(Instant.now().plus(Duration.ofSeconds(30)).toEpochMilli());

        assertThat(service.isValid(base64(payload) + "." + sign(payload, SECRET))).isTrue();
    }

    @Test
    void rejectsAnExtendedExpiryCarryingTheOriginalSignature() {
        // The obvious forgery: take a real token, push the expiry out, keep the
        // signature. The signature covers the expiry, so this must fail.
        String real = service.issueToken();
        String signature = real.substring(real.indexOf('.') + 1);
        String extended = Long.toString(Instant.now().plus(Duration.ofDays(3650)).toEpochMilli());

        assertThat(service.isValid(base64(extended) + "." + signature)).isFalse();
    }

    @Test
    void rejectsATokenSignedWithADifferentSecret() {
        String payload = Long.toString(Instant.now().plus(Duration.ofHours(1)).toEpochMilli());

        assertThat(service.isValid(base64(payload) + "." + sign(payload, "some-other-admin-secret"))).isFalse();
    }

    @Test
    void rejectsATamperedSignature() {
        String token = service.issueToken();
        int dot = token.indexOf('.');
        String signature = token.substring(dot + 1);
        char first = signature.charAt(0);
        String flipped = (first == 'A' ? 'B' : 'A') + signature.substring(1);

        assertThat(service.isValid(token.substring(0, dot + 1) + flipped)).isFalse();
    }

    @Test
    void rejectsMalformedInputWithoutThrowing() {
        // isValid receives an attacker-controlled header on every admin request.
        String[] malformed = {
                null,
                "",
                "   ",
                ".",
                "..",
                "no-dot",
                "!!!notbase64!!!.sig",
                base64("not-a-number") + ".sig",
                base64("") + ".sig",
                base64(Long.toString(Instant.now().plus(Duration.ofHours(1)).toEpochMilli())),  // no signature
                base64(Long.toString(Instant.now().plus(Duration.ofHours(1)).toEpochMilli())) + ".", // empty signature
        };

        for (String token : malformed) {
            assertThatCode(() -> service.isValid(token))
                    .as("isValid(%s) must not throw", token)
                    .doesNotThrowAnyException();
            assertThat(service.isValid(token))
                    .as("isValid(%s) must be false", token)
                    .isFalse();
        }
    }

    @Test
    void issuesATokenValidForRoughlyTwentyFourHours() {
        // The TTL is the only limit on a leaked admin token, since nothing can
        // revoke one. Asserted as a range so clock jitter cannot flake it.
        String token = service.issueToken();
        long expiry = Long.parseLong(new String(
                Base64.getUrlDecoder().decode(token.substring(0, token.indexOf('.'))), StandardCharsets.UTF_8));

        Instant expiresAt = Instant.ofEpochMilli(expiry);
        assertThat(expiresAt).isAfter(Instant.now().plus(Duration.ofHours(23)));
        assertThat(expiresAt).isBefore(Instant.now().plus(Duration.ofHours(25)));
    }

    @Test
    void keyHolderCanMintAValidTokenWithoutThePassword() {
        // Not a bug -- the documented consequence of a payload that carries only
        // an expiry. Anyone with the signing secret can produce a session
        // offline, never contacting the server and never knowing
        // careerguide.admin.password.
        //
        // Pinned deliberately: it is why the token secret must be treated as
        // equal in value to the admin password, and why ProdSecretsCheck rejects
        // the published default. If a future change adds identity or a
        // server-side store, this test should fail and be deleted on purpose.
        // The payload is computed once and reused: calling Instant.now() twice
        // signs a different millisecond than the one encoded, which fails for a
        // reason that has nothing to do with what this test is about.
        String payload = Long.toString(Instant.now().plus(Duration.ofHours(1)).toEpochMilli());
        String forgedOffline = base64(payload) + "." + sign(payload, SECRET);

        assertThat(service.isValid(forgedOffline)).isTrue();
    }

    @Test
    void tokensCarryNoIdentity() {
        // Two tokens differ only by the instant they were issued; neither says
        // who issued it, so admin actions cannot be attributed. Worth pinning
        // before anyone builds an audit log on top of this.
        String token = service.issueToken();
        String payload = new String(
                Base64.getUrlDecoder().decode(token.substring(0, token.indexOf('.'))), StandardCharsets.UTF_8);

        assertThat(payload).containsOnlyDigits();
    }

    @Test
    void anEmptySecretFailsOnFirstUseRatherThanSilentlyAcceptingEverything() {
        // Same shape as UserTokenService: the constructor takes "" without
        // complaint and the crash arrives at first issue. ProdSecretsCheck is
        // what stops that reaching a deployment; this records the cost if it
        // were ever relaxed. Failing loudly is the right half of it -- an empty
        // key must never degrade into "no signature required".
        AdminTokenService weak = new AdminTokenService("");

        assertThatCode(weak::issueToken).isInstanceOf(IllegalArgumentException.class);
    }

    private static String base64(String value) {
        return Base64.getUrlEncoder().withoutPadding().encodeToString(value.getBytes(StandardCharsets.UTF_8));
    }

    /** Independent reimplementation of the service's signature, for authentic and forged tokens. */
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
