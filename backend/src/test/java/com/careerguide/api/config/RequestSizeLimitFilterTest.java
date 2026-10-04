package com.careerguide.api.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import jakarta.servlet.FilterChain;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.junit.jupiter.api.Test;

import java.io.PrintWriter;
import java.io.StringWriter;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;

/**
 * Tests for {@link RequestSizeLimitFilter}.
 *
 * <p>Before this filter, a 2 MB {@code message} posted to the public counselling
 * endpoint was accepted and stored as 1953 kB. The {@code @Size(max = 2000)} now
 * on that field rejects the value, but only after Jackson has parsed the entire
 * body into memory -- that annotation protects the database column, not the heap.
 * This filter is the layer that refuses the body before anything reads it, and
 * these tests are about that distinction.
 */
class RequestSizeLimitFilterTest {

    private static final long LIMIT = 65_536;

    /**
     * JavaTimeModule is registered deliberately, not incidentally. ApiError's
     * timestamp is an {@link java.time.Instant}, and a bare ObjectMapper refuses
     * to serialise one -- the first draft of this test used one and failed with
     * "Java 8 date/time type not supported", while the real endpoint was fine.
     * Spring Boot's injected mapper has the module, so matching it here keeps the
     * test faithful instead of testing a mapper the application never uses.
     */
    private final RequestSizeLimitFilter filter = new RequestSizeLimitFilter(
            LIMIT, new ObjectMapper().registerModule(new JavaTimeModule()));

    @Test
    void anOversizedBodyIsRejectedAndNeverReachesTheApplication() throws Exception {
        // The chain must NOT be called. If it were, the body would be parsed and
        // the filter would be decorative.
        FilterChain chain = mock(FilterChain.class);
        StringWriter written = new StringWriter();

        filter.doFilterInternal(request(2_000_000), response(written), chain);

        verify(chain, never()).doFilter(any(), any());
        assertThat(written.toString()).contains("\"status\":413");
    }

    @Test
    void theRejectionBodyMatchesTheApiErrorShapeUsedEverywhereElse() throws Exception {
        // A filter runs outside the handler chain, so GlobalExceptionHandler never
        // sees this. Without writing the body here the caller would get Spring
        // Boot's default error page -- a different shape from every other error
        // this API returns, which is the kind of inconsistency a client parses
        // wrongly exactly once.
        StringWriter written = new StringWriter();

        filter.doFilterInternal(request(2_000_000), response(written), mock(FilterChain.class));

        String body = written.toString();
        assertThat(body)
                .contains("\"status\":413")
                .contains("\"error\":\"Payload Too Large\"")
                .contains("\"path\":\"/api/counselling-requests\"")
                .contains("\"timestamp\"");
        // The message names both numbers, so a caller can tell how far over it was.
        assertThat(body).contains("2000000").contains(String.valueOf(LIMIT));
    }

    @Test
    void aBodyWithinTheLimitPassesThrough() throws Exception {
        FilterChain chain = mock(FilterChain.class);

        filter.doFilterInternal(request(1_024), response(new StringWriter()), chain);

        verify(chain).doFilter(any(), any());
    }

    @Test
    void aBodyExactlyAtTheLimitPassesThrough() throws Exception {
        // The comparison is strictly greater-than, so the limit itself is allowed.
        // Pinned because an off-by-one here rejects a legitimate maximum payload.
        FilterChain chain = mock(FilterChain.class);

        filter.doFilterInternal(request(LIMIT), response(new StringWriter()), chain);

        verify(chain).doFilter(any(), any());
    }

    @Test
    void oneByteOverTheLimitIsRejected() throws Exception {
        FilterChain chain = mock(FilterChain.class);

        filter.doFilterInternal(request(LIMIT + 1), response(new StringWriter()), chain);

        verify(chain, never()).doFilter(any(), any());
    }

    @Test
    void aRequestWithNoContentLengthPassesThrough() throws Exception {
        // getContentLengthLong() returns -1 for a GET, and for a chunked request
        // that declares no length. Letting those through is deliberate and is the
        // filter's documented gap: a chunked body is bounded only by @Size after
        // parsing. Pinned so the behaviour is a known limitation rather than a
        // surprise, and so nobody "fixes" it into rejecting every GET.
        FilterChain chain = mock(FilterChain.class);

        filter.doFilterInternal(request(-1), response(new StringWriter()), chain);

        verify(chain).doFilter(any(), any());
    }

    private static HttpServletRequest request(long contentLength) {
        HttpServletRequest request = mock(HttpServletRequest.class);
        lenient().when(request.getContentLengthLong()).thenReturn(contentLength);
        lenient().when(request.getMethod()).thenReturn("POST");
        lenient().when(request.getRequestURI()).thenReturn("/api/counselling-requests");
        return request;
    }

    private static HttpServletResponse response(StringWriter target) {
        HttpServletResponse response = mock(HttpServletResponse.class);
        try {
            lenient().when(response.getWriter()).thenReturn(new PrintWriter(target, true));
        } catch (Exception e) {
            throw new IllegalStateException(e);
        }
        return response;
    }
}
