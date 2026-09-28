package com.careerguide.api.service;

import org.springframework.stereotype.Service;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import java.security.GeneralSecurityException;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * Hashes and verifies user passwords with PBKDF2WithHmacSHA256 -- a standard
 * javax.crypto algorithm, not bcrypt/Argon2, deliberately: this project
 * hand-rolls its own crypto already (see AdminTokenService's HMAC signing)
 * rather than pulling in Spring Security, and the sandbox this was built in
 * has no network access to Maven Central to add or verify a new dependency
 * (a real bcrypt library) at all. PBKDF2 with a high iteration count is a
 * legitimate, standard choice -- just not the most common one for this --
 * and needs nothing beyond the JDK.
 *
 * <p>A hash is stored as a single self-describing string:
 * {@code pbkdf2:<iterations>:<base64 salt>:<base64 hash>}, so the iteration
 * count can be raised later without invalidating passwords hashed under the
 * old count.
 */
@Service
public class UserPasswordService {

    private static final String ALGORITHM = "PBKDF2WithHmacSHA256";
    private static final int ITERATIONS = 210_000;
    private static final int KEY_LENGTH_BITS = 256;
    private static final int SALT_LENGTH_BYTES = 16;

    private final SecureRandom secureRandom = new SecureRandom();

    public String hash(String rawPassword) {
        byte[] salt = new byte[SALT_LENGTH_BYTES];
        secureRandom.nextBytes(salt);
        byte[] hash = pbkdf2(rawPassword, salt, ITERATIONS);
        return "pbkdf2:" + ITERATIONS + ":" + encode(salt) + ":" + encode(hash);
    }

    public boolean matches(String rawPassword, String storedHash) {
        String[] parts = storedHash.split(":");
        if (parts.length != 4 || !"pbkdf2".equals(parts[0])) {
            return false;
        }
        int iterations;
        byte[] salt;
        byte[] expectedHash;
        try {
            iterations = Integer.parseInt(parts[1]);
            salt = decode(parts[2]);
            expectedHash = decode(parts[3]);
        } catch (IllegalArgumentException malformed) {
            return false;
        }
        byte[] actualHash = pbkdf2(rawPassword, salt, iterations);
        return java.security.MessageDigest.isEqual(actualHash, expectedHash);
    }

    private byte[] pbkdf2(String rawPassword, byte[] salt, int iterations) {
        PBEKeySpec spec = new PBEKeySpec(rawPassword.toCharArray(), salt, iterations, KEY_LENGTH_BITS);
        try {
            SecretKeyFactory factory = SecretKeyFactory.getInstance(ALGORITHM);
            return factory.generateSecret(spec).getEncoded();
        } catch (GeneralSecurityException e) {
            // PBKDF2WithHmacSHA256 is a standard JDK algorithm; unreachable
            // in practice, same reasoning as AdminTokenService's HMAC catch.
            throw new IllegalStateException("Failed to hash password", e);
        } finally {
            spec.clearPassword();
        }
    }

    private String encode(byte[] value) {
        return Base64.getUrlEncoder().withoutPadding().encodeToString(value);
    }

    private byte[] decode(String value) {
        return Base64.getUrlDecoder().decode(value);
    }
}
