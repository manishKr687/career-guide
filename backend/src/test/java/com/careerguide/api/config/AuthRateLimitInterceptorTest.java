package com.careerguide.api.config;

import com.careerguide.api.web.RateLimitExceededException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

/**
 * Tests the two-budget behaviour of {@link AuthRateLimitInterceptor}.
 *
 * <p>{@code POST /api/counselling-requests} is the only unauthenticated endpoint
 * in this API that persists anything, and it was unthrottled. Measured before
 * the fix: thirty submissions back to back returned thirty 201s. The risk is not
 * a password being guessed -- it is unbounded growth of a table holding names,
 * email addresses and phone numbers of students who are often minors, and an
 * admin inbox nobody can use.
 *
 * <p>So it gets a tighter budget than the credential endpoints, and the thing
 * most worth pinning is that the two budgets stay separate. A single shared
 * number would eventually be tuned for whichever endpoint complained most
 * recently: raise it for the form and brute-force protection weakens, lower it
 * for login and a user who mistypes their password three times is locked out.
 */
class AuthRateLimitInterceptorTest {

    private static final int AUTH_BUDGET = 10;
    private static final int SUBMISSION_BUDGET = 3;

    private final AuthRateLimiter limiter = new AuthRateLimiter(AUTH_BUDGET, 900);
    private final AuthRateLimitInterceptor interceptor =
            new AuthRateLimitInterceptor(limiter, SUBMISSION_BUDGET);

    @Test
    void theCounsellingFormIsThrottledAtTheSubmissionBudget() {
        HttpServletRequest request = post("/api/counselling-requests", "203.0.113.5");
        HttpServletResponse response = mock(HttpServletResponse.class);

        for (int i = 1; i <= SUBMISSION_BUDGET; i++) {
            int attempt = i;
            assertThatCode(() -> interceptor.preHandle(request, response, null))
                    .as("attempt %d of %d should be allowed", attempt, SUBMISSION_BUDGET)
                    .doesNotThrowAnyException();
        }

        assertThatThrownBy(() -> interceptor.preHandle(request, response, null))
                .isInstanceOf(RateLimitExceededException.class);
    }

    @Test
    void credentialEndpointsKeepTheirOwnLargerBudget() {
        // The regression this guards: wiring the form through the same
        // interceptor must not drag login down to three attempts. Three is right
        // for a form and hostile to a person who mistyped their password.
        HttpServletResponse response = mock(HttpServletResponse.class);

        for (String path : new String[]{"/api/auth/login", "/api/auth/register", "/api/admin/login"}) {
            HttpServletRequest request = post(path, "203.0.113.6");
            for (int i = 1; i <= AUTH_BUDGET; i++) {
                int attempt = i;
                assertThatCode(() -> interceptor.preHandle(request, response, null))
                        .as("%s attempt %d of %d should be allowed", path, attempt, AUTH_BUDGET)
                        .doesNotThrowAnyException();
            }
            assertThatThrownBy(() -> interceptor.preHandle(request, response, null))
                    .as("%s should be limited after %d", path, AUTH_BUDGET)
                    .isInstanceOf(RateLimitExceededException.class);
        }
    }

    @Test
    void theTwoBudgetsDoNotShareABucket() {
        // Keyed by ip:path, so exhausting the form must not lock the same caller
        // out of logging in -- otherwise spamming the public form becomes a way
        // to deny someone their own account.
        HttpServletResponse response = mock(HttpServletResponse.class);
        HttpServletRequest form = post("/api/counselling-requests", "203.0.113.7");
        HttpServletRequest login = post("/api/auth/login", "203.0.113.7");

        for (int i = 0; i < SUBMISSION_BUDGET + 2; i++) {
            try {
                interceptor.preHandle(form, response, null);
            } catch (RateLimitExceededException expected) {
                // exhausting it is the point
            }
        }

        assertThatCode(() -> interceptor.preHandle(login, response, null))
                .doesNotThrowAnyException();
    }

    @Test
    void differentCallersAreCountedSeparately() {
        // Otherwise one abusive IP takes the form offline for everyone, turning a
        // throttle into the denial of service it exists to prevent.
        HttpServletResponse response = mock(HttpServletResponse.class);
        HttpServletRequest abuser = post("/api/counselling-requests", "203.0.113.8");
        HttpServletRequest student = post("/api/counselling-requests", "203.0.113.9");

        for (int i = 0; i < SUBMISSION_BUDGET + 5; i++) {
            try {
                interceptor.preHandle(abuser, response, null);
            } catch (RateLimitExceededException expected) {
                // expected
            }
        }

        assertThatCode(() -> interceptor.preHandle(student, response, null))
                .doesNotThrowAnyException();
    }

    @Test
    void aRejectionSetsRetryAfterSoTheClientKnowsHowLongToWait() {
        HttpServletRequest request = post("/api/counselling-requests", "203.0.113.10");
        HttpServletResponse response = mock(HttpServletResponse.class);

        for (int i = 0; i < SUBMISSION_BUDGET; i++) {
            interceptor.preHandle(request, response, null);
        }
        assertThatThrownBy(() -> interceptor.preHandle(request, response, null))
                .isInstanceOf(RateLimitExceededException.class);

        verify(response).setHeader(eq("Retry-After"), anyString());
    }

    @Test
    void corsPreflightIsNotCounted() {
        // An OPTIONS carries no submission, and counting it would let a browser's
        // own preflight consume a third of the caller's budget before the real
        // request arrives.
        HttpServletResponse response = mock(HttpServletResponse.class);
        HttpServletRequest preflight = mock(HttpServletRequest.class);
        lenient().when(preflight.getMethod()).thenReturn("OPTIONS");
        lenient().when(preflight.getRequestURI()).thenReturn("/api/counselling-requests");
        lenient().when(preflight.getRemoteAddr()).thenReturn("203.0.113.11");

        for (int i = 0; i < 50; i++) {
            assertThat(interceptor.preHandle(preflight, response, null)).isTrue();
        }

        // The budget is untouched, so a real POST from the same caller still works.
        assertThatCode(() -> interceptor.preHandle(post("/api/counselling-requests", "203.0.113.11"), response, null))
                .doesNotThrowAnyException();
    }

    @Test
    void xForwardedForIsPreferredOverTheSocketAddress() {
        // Behind a reverse proxy every request arrives from the proxy's address,
        // so without this one bucket would be shared by the whole internet and
        // the throttle would lock out all callers at once.
        HttpServletResponse response = mock(HttpServletResponse.class);
        HttpServletRequest viaProxy = mock(HttpServletRequest.class);
        lenient().when(viaProxy.getMethod()).thenReturn("POST");
        lenient().when(viaProxy.getRequestURI()).thenReturn("/api/counselling-requests");
        lenient().when(viaProxy.getRemoteAddr()).thenReturn("10.0.0.1");          // the proxy
        lenient().when(viaProxy.getHeader("X-Forwarded-For")).thenReturn("198.51.100.4, 10.0.0.1");

        for (int i = 0; i < SUBMISSION_BUDGET; i++) {
            interceptor.preHandle(viaProxy, response, null);
        }
        assertThatThrownBy(() -> interceptor.preHandle(viaProxy, response, null))
                .isInstanceOf(RateLimitExceededException.class);

        // A different forwarded client behind the same proxy is unaffected.
        HttpServletRequest otherClient = mock(HttpServletRequest.class);
        lenient().when(otherClient.getMethod()).thenReturn("POST");
        lenient().when(otherClient.getRequestURI()).thenReturn("/api/counselling-requests");
        lenient().when(otherClient.getRemoteAddr()).thenReturn("10.0.0.1");
        lenient().when(otherClient.getHeader("X-Forwarded-For")).thenReturn("198.51.100.5");

        assertThatCode(() -> interceptor.preHandle(otherClient, response, null))
                .doesNotThrowAnyException();
    }

    private static HttpServletRequest post(String path, String ip) {
        HttpServletRequest request = mock(HttpServletRequest.class);
        lenient().when(request.getMethod()).thenReturn("POST");
        lenient().when(request.getRequestURI()).thenReturn(path);
        lenient().when(request.getRemoteAddr()).thenReturn(ip);
        lenient().when(request.getHeader("X-Forwarded-For")).thenReturn(null);
        return request;
    }
}
