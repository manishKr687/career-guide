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
import java.util.Optional;

/**
 * Issues and verifies consumer session tokens -- same self-contained,
 * no-database-table design as {@link AdminTokenService}, extended to carry
 * a user id in the payload (admin tokens don't identify anyone, since
 * there's only one admin). A token is
 * "{@code <base64url userId.expiryEpochMillis>.<base64url HMAC-SHA256 signature>}",
 * verified by recomputing the signature with a server-side secret
 * ({@code careerguide.user.token-secret}) and checking the expiry.
 */
@Service
public class UserTokenService {

    private static final String HMAC_ALGORITHM = "HmacSHA256";
    private static final Duration TOKEN_TTL = Duration.ofDays(30);

    private final byte[] secretKeyBytes;

    public UserTokenService(@Value("${careerguide.user.token-secret}") String secret) {
        this.secretKeyBytes = secret.getBytes(StandardCharsets.UTF_8);
    }

    public String issueToken(long userId) {
        String payload = userId + "." + Instant.now().plus(TOKEN_TTL).toEpochMilli();
        return encode(payload) + "." + sign(payload);
    }

    /**
     * @return the user id carried by {@code token}, if it is well-formed,
     * correctly signed, and not expired.
     */
    public Optional<Long> resolveUserId(String token) {
        if (token == null || token.isBlank()) {
            return Optional.empty();
        }
        int dot = token.indexOf('.');
        if (dot < 0) {
            return Optional.empty();
        }
        String payload;
        try {
            payload = decode(token.substring(0, dot));
        } catch (IllegalArgumentException malformedBase64) {
            return Optional.empty();
        }
        String suppliedSignature = token.substring(dot + 1);
        String expectedSignature = sign(payload);
        if (!MessageDigest.isEqual(
                suppliedSignature.getBytes(StandardCharsets.UTF_8),
                expectedSignature.getBytes(StandardCharsets.UTF_8))) {
            return Optional.empty();
        }
        String[] parts = payload.split("\\.");
        if (parts.length != 2) {
            return Optional.empty();
        }
        try {
            long userId = Long.parseLong(parts[0]);
            long expiryEpochMillis = Long.parseLong(parts[1]);
            if (Instant.now().isBefore(Instant.ofEpochMilli(expiryEpochMillis))) {
                return Optional.of(userId);
            }
            return Optional.empty();
        } catch (NumberFormatException notANumber) {
            return Optional.empty();
        }
    }

    private String sign(String payload) {
        try {
            Mac mac = Mac.getInstance(HMAC_ALGORITHM);
            mac.init(new SecretKeySpec(secretKeyBytes, HMAC_ALGORITHM));
            byte[] raw = mac.doFinal(payload.getBytes(StandardCharsets.UTF_8));
            return Base64.getUrlEncoder().withoutPadding().encodeToString(raw);
        } catch (java.security.GeneralSecurityException e) {
            throw new IllegalStateException("Failed to sign user token", e);
        }
    }

    private String encode(String value) {
        return Base64.getUrlEncoder().withoutPadding().encodeToString(value.getBytes(StandardCharsets.UTF_8));
    }

    private String decode(String value) {
        return new String(Base64.getUrlDecoder().decode(value), StandardCharsets.UTF_8);
    }
}
