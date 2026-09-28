package com.careerguide.api.dto;

import java.time.Instant;
import java.util.List;

/**
 * Everything the admin dashboard renders, in one payload.
 *
 * <p>Deliberately NOT assembled from the entity DTOs. A dashboard asks
 * aggregate questions -- how many, what changed, what is missing -- and
 * answering those by fetching 1,200 full records and counting them in the
 * browser is both slow and a different shape from the question.
 *
 * <p>The numbers here are all counted from the database at request time.
 * There are no growth percentages: nothing in this schema records history for
 * catalog content, so "+12% vs last month" could only be invented.
 */
public record AdminDashboardDto(
        List<EntityCount> counts,
        /** Content the catalog is missing, most significant first. */
        List<ContentGap> gaps,
        /** Rows created or edited since V115 added timestamps. */
        List<RecentChange> recentChanges,
        List<RecentUser> recentUsers,
        long totalUsers,
        long counsellingRequests,
        long pendingCounsellingRequests,
        /**
         * How many catalog rows predate V115 and so have no creation date.
         * Surfaced rather than hidden: it is why the recent-changes list is
         * short, and it shrinks on its own as content is edited.
         */
        long undatedRows
) {
    /** One tile: an entity type and how many of it exist. */
    public record EntityCount(String entity, String label, long count, String adminPath) {}

    /**
     * A measurable hole in the catalog -- "0 of 42 careers have salary bands".
     * Each one is a real query, not a guess, so the dashboard shows what needs
     * work instead of a growth chart nobody can act on.
     */
    public record ContentGap(String label, long affected, long total, String detail, String adminPath) {}

    public record RecentChange(String entity, String label, String slug, String title, Instant at, boolean isNew) {}

    public record RecentUser(String name, String email, Instant joinedAt) {}
}
