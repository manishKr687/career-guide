package com.careerguide.api.config;

import com.careerguide.api.web.ApiError;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

/**
 * Rejects a request body larger than {@code careerguide.max-request-bytes}
 * before anything reads it.
 *
 * <p>Bean Validation cannot do this job. {@code @Size} on a field runs after
 * Jackson has already parsed the whole body into memory, so a 100 MB JSON
 * document is fully deserialised and only then rejected -- the validation
 * protects the database column, not the heap. Spring Boot has no property that
 * caps a JSON body either: {@code server.tomcat.max-http-form-post-size}
 * applies to form-encoded posts only, which this API does not accept.
 *
 * <p>This exists because {@code POST /api/counselling-requests} is
 * unauthenticated and writes a row. Before this, a 2 MB message was accepted
 * and stored, with nothing limiting how often. The rate limiter now bounds the
 * count and {@code @Size} bounds the stored text; this bounds what is read into
 * memory in the first place, which is the part neither of the others covers.
 *
 * <h2>The chunked-encoding gap, stated rather than glossed</h2>
 *
 * This check reads {@code Content-Length}. A client using
 * {@code Transfer-Encoding: chunked} sends no such header, and this filter lets
 * it through -- the request is then bounded only by {@code @Size} after parsing.
 * Closing that properly means wrapping the input stream and counting bytes as
 * they are read, which is a different and more invasive change. What is here
 * stops the realistic case (any ordinary HTTP client, including curl, sends
 * Content-Length) and the gap is recorded so nobody assumes otherwise.
 */
@Component
public class RequestSizeLimitFilter extends OncePerRequestFilter {

    private static final Logger log = LoggerFactory.getLogger(RequestSizeLimitFilter.class);

    private final long maxRequestBytes;
    private final ObjectMapper objectMapper;

    public RequestSizeLimitFilter(
            @Value("${careerguide.max-request-bytes:65536}") long maxRequestBytes,
            ObjectMapper objectMapper) {
        this.maxRequestBytes = maxRequestBytes;
        this.objectMapper = objectMapper;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {

        long declared = request.getContentLengthLong();
        if (declared > maxRequestBytes) {
            // Logged at warn because on a public endpoint this is somebody
            // probing rather than a user mistyping: 64 KB is far beyond any
            // legitimate form submission this API accepts.
            log.warn("Rejected {} {} -- body declares {} bytes, limit is {}",
                    request.getMethod(), request.getRequestURI(), declared, maxRequestBytes);
            writeError(request, response, declared);
            return;
        }
        chain.doFilter(request, response);
    }

    /**
     * Matches {@link com.careerguide.api.web.GlobalExceptionHandler}'s body
     * shape. A filter runs outside the handler chain, so the exception handler
     * never sees this -- without writing the body here the caller would get
     * Spring Boot's default error page, differently shaped from every other
     * error this API returns.
     */
    private void writeError(HttpServletRequest request, HttpServletResponse response, long declared)
            throws IOException {
        ApiError body = ApiError.of(
                HttpStatus.PAYLOAD_TOO_LARGE.value(),
                "Payload Too Large",
                "Request body is too large (" + declared + " bytes; the limit is " + maxRequestBytes + ").",
                request.getRequestURI());
        response.setStatus(HttpStatus.PAYLOAD_TOO_LARGE.value());
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        objectMapper.writeValue(response.getWriter(), body);
    }
}
