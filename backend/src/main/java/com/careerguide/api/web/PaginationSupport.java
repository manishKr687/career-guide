package com.careerguide.api.web;

import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;

/**
 * Resolves optional {@code page}/{@code size} query params into a
 * {@link Pageable}, defaulting to {@link Pageable#unpaged()} when neither is
 * given.
 *
 * <p>This exists so the public catalog list endpoints (careers, courses,
 * exams, colleges) can gain real pagination without a breaking change: the
 * Next.js frontend's data-layer helpers (career-guide's {@code src/data/*.ts})
 * call these endpoints expecting a bare JSON array of "everything matching
 * this filter" and decode the response as {@code T[]} with no envelope. If
 * these endpoints started always returning a paginated envelope (or only
 * the first page by default), that would silently truncate or break every
 * existing caller. Defaulting to unpaged keeps today's callers working
 * exactly as before; a caller that explicitly passes {@code page} and/or
 * {@code size} opts into real paging, and reads the total row count from
 * the {@code X-Total-Count} response header the controller sets alongside
 * it (see e.g. {@code CareerController.findAll}) rather than from the body,
 * so the body stays a plain array either way.
 */
public final class PaginationSupport {

    private static final int DEFAULT_SIZE = 20;
    private static final int MAX_SIZE = 200;

    private PaginationSupport() {
    }

    public static Pageable resolve(Integer page, Integer size) {
        if (page == null && size == null) {
            return Pageable.unpaged();
        }
        int resolvedPage = page == null ? 0 : Math.max(page, 0);
        int resolvedSize = size == null ? DEFAULT_SIZE : Math.min(Math.max(size, 1), MAX_SIZE);
        return PageRequest.of(resolvedPage, resolvedSize);
    }
}
