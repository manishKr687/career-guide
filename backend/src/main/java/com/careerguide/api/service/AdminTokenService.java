package com.careerguide.api.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.Duration;
import java.time.Instant;
import java.util.Base64;

/**
 * Issues and verifies short-lived admin session tokens without a database
 * table or a server-side session store. A token is
 * "{@code <base64url expiry-epoch-millis>.<base64url HMAC-SHA256 signature>}",
 * verified by recomputing the signature with a server-side secret
 * ({@code careerguide.admin.token-secret}) and checking the expiry.
 *
 * <p>There is deliberately no per-user identity here: anyone holding a valid
 * token can act as the single admin configured via
 * {@code careerguide.admin.password}. That matches the "one shared admin
 * password, no user accounts" scope agreed for the admin panel -- if this
 * ever needs multiple distinct admins, this is the place a real users table
 * would replace this class.
 */
@Service
public class AdminTokenService {

    private static final String HMAC_ALGORITHM = "HmacSHA256";
    private static final Duration TOKEN_TTL = Duration.ofHours(24);

    private final byte[] secretKeyBytes;

    public AdminTokenService(@Value("${careerguide.admin.token-secret}") String secret) {
        this.secretKeyBytes = secret.getBytes(StandardCharsets.UTF_8);
    }

    public String issueToken() {
        String payload = Long.toString(Instant.now().plus(TOKEN_TTL).toEpochMilli());
        return encode(payload) + "." + sign(payload);
    }

    public boolean isValid(String token) {
        if (token == null || token.isBlank()) {
            return false;
        }
        int dot = token.indexOf('.');
        if (dot < 0) {
            return false;
        }
        String payload;
        try {
            payload = decode(token.substring(0, dot));
        } catch (IllegalArgumentException malformedBase64) {
            return false;
        }
        String suppliedSignature = token.substring(dot + 1);
        String expectedSignature = sign(payload);
        if (!MessageDigest.isEqual(
                suppliedSignature.getBytes(StandardCharsets.UTF_8),
                expectedSignature.getBytes(StandardCharsets.UTF_8))) {
            return false;
        }
        try {
            long expiryEpochMillis = Long.parseLong(payload);
            return Instant.now().isBefore(Instant.ofEpochMilli(expiryEpochMillis));
        } catch (NumberFormatException notANumber) {
            return false;
        }
    }

    private String sign(String payload) {
        try {
            Mac mac = Mac.getInstance(HMAC_ALGORITHM);
            mac.init(new SecretKeySpec(secretKeyBytes, HMAC_ALGORITHM));
            byte[] raw = mac.doFinal(payload.getBytes(StandardCharsets.UTF_8));
            return Base64.getUrlEncoder().withoutPadding().encodeToString(raw);
        } catch (java.security.GeneralSecurityException e) {
            // HmacSHA256 is a standard JDK algorithm; this is unreachable in
            // practice, but the checked exception still has to go somewhere.
            throw new IllegalStateException("Failed to sign admin token", e);
        }
    }

    private String encode(String value) {
        return Base64.getUrlEncoder().withoutPadding().encodeToString(value.getBytes(StandardCharsets.UTF_8));
    }

    private String decode(String value) {
        return new String(Base64.getUrlDecoder().decode(value), StandardCharsets.UTF_8);
    }
}
