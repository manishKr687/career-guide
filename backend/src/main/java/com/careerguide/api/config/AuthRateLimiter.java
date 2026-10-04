package com.careerguide.api.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.util.concurrent.ConcurrentHashMap;

/**
 * In-memory, fixed-window request counter keyed by an arbitrary caller
 * string (here, "{@code ip:path}" -- see {@link AuthRateLimitInterceptor}).
 * No new dependency (no Bucket4j/Redis/etc): this is intentionally the
 * simplest thing that stops a naive credential-stuffing or registration-spam
 * script, not a distributed or perimeter-grade rate limiter. A single
 * instance's counters are per-JVM, which is fine for this app's single
 * backend instance; it would need a shared store (Redis) to work correctly
 * behind more than one instance.
 *
 * <p>Window semantics: each key gets a counter that resets
 * {@code windowSeconds} after its *first* hit in the current window (fixed
 * window, not sliding) -- simple, and close enough for "basic" throttling.
 * A key can therefore burst up to {@code maxAttempts} twice back-to-back
 * right at a window boundary; that trade-off is accepted for the
 * simplicity of not tracking a timestamp per attempt.
 */
@Component
public class AuthRateLimiter {

    /** Bounds memory: once this many distinct keys are tracked, expired ones are swept. */
    private static final int SWEEP_THRESHOLD = 10_000;

    private final int maxAttempts;
    private final long windowMillis;
    private final ConcurrentHashMap<String, Bucket> buckets = new ConcurrentHashMap<>();

    public AuthRateLimiter(
            @Value("${careerguide.rate-limit.auth.max-attempts:10}") int maxAttempts,
            @Value("${careerguide.rate-limit.auth.window-seconds:900}") long windowSeconds) {
        this.maxAttempts = maxAttempts;
        this.windowMillis = windowSeconds * 1000L;
    }

    /**
     * Records one attempt for {@code key} and reports whether it's still
     * within the configured budget for the current window.
     */
    public boolean tryAcquire(String key) {
        return tryAcquire(key, maxAttempts);
    }

    /**
     * As {@link #tryAcquire(String)}, but against a caller-supplied budget.
     *
     * <p>Added so one limiter can serve groups of endpoints with different
     * threat models. The configured default suits credential guessing, where
     * ten tries per quarter hour is already generous. A public form wants a
     * tighter number: nobody submits a counselling enquiry ten times, so the
     * extra headroom buys a legitimate user nothing and an abuser something.
     *
     * <p>Additive on purpose -- the no-argument overload behaves exactly as
     * before, so the login and registration paths are untouched.
     */
    public boolean tryAcquire(String key, int budget) {
        long now = System.currentTimeMillis();
        sweepIfNeeded(now);
        Bucket bucket = buckets.computeIfAbsent(key, ignored -> new Bucket(now));
        synchronized (bucket) {
            if (now - bucket.windowStart >= windowMillis) {
                bucket.windowStart = now;
                bucket.count = 0;
            }
            bucket.count++;
            return bucket.count <= budget;
        }
    }

    /** Seconds until {@code key}'s current window resets, for a caller-facing message. */
    public long retryAfterSeconds(String key) {
        Bucket bucket = buckets.get(key);
        if (bucket == null) {
            return 0;
        }
        synchronized (bucket) {
            long elapsed = System.currentTimeMillis() - bucket.windowStart;
            return Math.max(0, (windowMillis - elapsed) / 1000);
        }
    }

    private void sweepIfNeeded(long now) {
        if (buckets.size() < SWEEP_THRESHOLD) {
            return;
        }
        buckets.entrySet().removeIf(entry -> now - entry.getValue().windowStart >= windowMillis);
    }

    private static final class Bucket {
        private long windowStart;
        private int count;

        private Bucket(long windowStart) {
            this.windowStart = windowStart;
            this.count = 0;
        }
    }
}
