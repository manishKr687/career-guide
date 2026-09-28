package com.careerguide.api.config;

import org.springframework.beans.factory.config.BeanFactoryPostProcessor;
import org.springframework.beans.factory.config.ConfigurableListableBeanFactory;
import org.springframework.context.EnvironmentAware;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.core.env.Environment;

import java.util.Set;

/**
 * Refuses to start under the {@code prod} profile if any secret is still one of
 * the development defaults published in this repository.
 *
 * <p>WHY A RUNTIME CHECK AND NOT JUST {@code application-prod.yml}. That file
 * declares each secret with no default, which makes Spring fail on an
 * <em>unset</em> environment variable. It is not enough on its own, because
 * {@code docker-compose.yml} supplies its own {@code :-} fallbacks -- so the
 * variable is always present inside the container and the placeholder always
 * resolves. Without this class, a deployment that used the compose file and set
 * {@code SPRING_PROFILES_ACTIVE=prod} but no secrets would boot on
 * {@code admin123} and look correctly configured. The two defences are
 * complementary: the profile catches a missing variable, this catches a
 * present-but-published one.
 *
 * <p>WHY A {@link BeanFactoryPostProcessor} AND NOT A CONSTRUCTOR. As an
 * ordinary bean this ran <em>after</em> {@code flywayInitializer}, so on a
 * deployment with both a bad password and an unreachable database the operator
 * got a connection error and never learned the secrets were wrong. A
 * BeanFactoryPostProcessor runs before any singleton is instantiated, so
 * configuration is validated before anything tries to use it.
 *
 * <p>WHY THE SIGNING KEYS MATTER MORE THAN THE PASSWORD. An admin token is an
 * HMAC over an expiry timestamp and nothing else (see AdminTokenService), so
 * the signing key alone mints a valid admin session offline -- no login
 * request, so the rate limiter never sees it, and rotating the password does
 * not help. UserTokenService signs {@code "<userId>.<expiry>"}, so its key
 * forges a session for any user. Hence the length floor on both, and none on
 * the password, which is rate-limited and only ever compared.
 *
 * <p>Failing at startup is deliberate. A warning in a log nobody reads is how
 * a placeholder key reaches production.
 */
@Configuration
@Profile("prod")
public class ProdSecretsCheck implements BeanFactoryPostProcessor, EnvironmentAware {

    /**
     * Every fallback value committed to this repository. Listed literally,
     * because the point is to reject exactly the strings an attacker can read
     * in application.yml and docker-compose.yml.
     */
    private static final Set<String> PUBLISHED_DEFAULTS = Set.of(
            "admin123",
            "dev-only-change-this-admin-token-secret",
            "dev-only-change-this-user-token-secret",
            "careerguide");

    /**
     * An HMAC-SHA256 key shorter than its 256-bit block gains nothing from the
     * algorithm. 32 characters is the floor, not a recommendation -- generate
     * these with {@code openssl rand -base64 48} rather than typing one.
     */
    private static final int MIN_SIGNING_KEY_LENGTH = 32;

    private Environment environment;

    @Override
    public void setEnvironment(Environment environment) {
        this.environment = environment;
    }

    @Override
    public void postProcessBeanFactory(ConfigurableListableBeanFactory beanFactory) {
        require("CAREERGUIDE_ADMIN_PASSWORD", "careerguide.admin.password");
        require("CAREERGUIDE_ADMIN_TOKEN_SECRET", "careerguide.admin.token-secret");
        require("CAREERGUIDE_USER_TOKEN_SECRET", "careerguide.user.token-secret");
        require("SPRING_DATASOURCE_PASSWORD", "spring.datasource.password");

        requireLength("CAREERGUIDE_ADMIN_TOKEN_SECRET", "careerguide.admin.token-secret");
        requireLength("CAREERGUIDE_USER_TOKEN_SECRET", "careerguide.user.token-secret");

        // Not a secret, but a localhost-only CORS policy on a deployed instance
        // means every browser request from the real frontend fails, which is a
        // confusing way to discover a missing variable.
        String origins = value("careerguide.cors.allowed-origins");
        if (origins != null && origins.contains("localhost")) {
            throw new IllegalStateException(
                    "CAREERGUIDE_CORS_ALLOWED_ORIGINS still allows localhost under the prod profile ("
                            + origins + "). Set it to the real frontend origin(s).");
        }
    }

    private String value(String property) {
        return environment.getProperty(property);
    }

    private void require(String envVar, String property) {
        String value = value(property);
        if (value == null || value.isBlank()) {
            throw new IllegalStateException(
                    envVar + " must be set under the prod profile (it is currently empty).");
        }
        if (PUBLISHED_DEFAULTS.contains(value)) {
            throw new IllegalStateException(
                    envVar + " is still the development default committed to this repository, which is "
                            + "public. Set a real value before running with the prod profile.");
        }
    }

    private void requireLength(String envVar, String property) {
        String value = value(property);
        if (value != null && value.length() < MIN_SIGNING_KEY_LENGTH) {
            throw new IllegalStateException(
                    envVar + " is " + value.length() + " characters; it signs session tokens and must be at "
                            + "least " + MIN_SIGNING_KEY_LENGTH + ". Generate one with: openssl rand -base64 48");
        }
    }
}
