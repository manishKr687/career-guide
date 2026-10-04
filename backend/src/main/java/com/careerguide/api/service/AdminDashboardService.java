package com.careerguide.api.service;

import com.careerguide.api.dto.AdminDashboardDto;
import com.careerguide.api.dto.AdminDashboardDto.ContentGap;
import com.careerguide.api.dto.AdminDashboardDto.EntityCount;
import com.careerguide.api.dto.AdminDashboardDto.RecentChange;
import com.careerguide.api.dto.AdminDashboardDto.RecentUser;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Timestamp;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

/**
 * Builds the admin dashboard payload with aggregate SQL rather than by
 * loading entities.
 *
 * <p>Native queries on purpose. Every question here is a COUNT or a small
 * ORDER BY ... LIMIT across ten unrelated tables; expressing that through JPA
 * would mean ten repositories and ten round trips to produce a page of
 * numbers. The queries are plain SQL over tables this application owns.
 *
 * <p>NO GROWTH PERCENTAGES. A dashboard usually shows "+12% vs last month"
 * next to each figure, and this one deliberately does not: catalog content
 * has no history in this schema -- V115 added creation timestamps but did not
 * backfill them, precisely so nothing would claim a date it does not have.
 * A month-over-month number would have to be fabricated, and it is the kind
 * of figure people act on.
 */
@Service
@Transactional(readOnly = true)
public class AdminDashboardService {

    /** entity key, display label, table, admin path. */
    private static final String[][] ENTITIES = {
            {"careers", "Careers", "careers", "/admin/careers"},
            {"degrees", "Degrees", "degrees", "/admin/degrees"},
            {"exams", "Exams", "exams", "/admin/exams"},
            {"colleges", "Colleges", "colleges", "/admin/colleges"},
            {"specializations", "Specializations", "specializations", "/admin/specializations"},
            {"jobRoles", "Job Roles", "job_roles", "/admin/job-roles"},
            {"skills", "Skills", "skills", "/admin/skills"},
            {"resources", "Resources", "resources", "/admin/resources"},
            {"certifications", "Certifications", "certifications", "/admin/certifications"},
            {"industries", "Industries", "industries", "/admin/industries"},
    };

    @PersistenceContext
    private EntityManager em;

    public AdminDashboardDto build() {
        List<EntityCount> counts = new ArrayList<>();
        for (String[] e : ENTITIES) {
            counts.add(new EntityCount(e[0], e[1], count("SELECT count(*) FROM " + e[2]), e[3]));
        }

        return new AdminDashboardDto(
                counts,
                gaps(),
                recentChanges(),
                recentUsers(),
                count("SELECT count(*) FROM users"),
                count("SELECT count(*) FROM counselling_requests"),
                count("SELECT count(*) FROM counselling_requests WHERE status = 'PENDING'"),
                undatedRows()
        );
    }

    /**
     * The holes worth acting on. Each is a real query against real columns --
     * these are the same gaps that kept surfacing while the pages were built,
     * which is exactly why they belong on the dashboard rather than in
     * somebody's notes.
     */
    private List<ContentGap> gaps() {
        List<ContentGap> gaps = new ArrayList<>();

        long careers = count("SELECT count(*) FROM careers");
        gaps.add(new ContentGap(
                "Careers without a salary breakdown",
                careers - count("SELECT count(DISTINCT career_slug) FROM career_salary_bands"),
                careers,
                "The per-level bands are unset, so the page shows only the overall range.",
                "/admin/careers"));

        long colleges = count("SELECT count(*) FROM colleges");
        gaps.add(new ContentGap(
                "Colleges without an NIRF rank",
                colleges - count("SELECT count(*) FROM colleges WHERE nirf_rank IS NOT NULL"),
                colleges,
                "The rank badge, the ranking filter and the Top Ranked rail stay hidden until a rank is entered.",
                "/admin/colleges"));

        long specializations = count("SELECT count(*) FROM specializations");
        gaps.add(new ContentGap(
                "Specializations with no content of their own",
                specializations - count("SELECT count(*) FROM specializations WHERE overview IS NOT NULL"),
                specializations,
                "These pages fall back to the parent career's data, labelled as borrowed.",
                "/admin/specializations"));

        long skills = count("SELECT count(*) FROM skills");
        gaps.add(new ContentGap(
                "Skills no career lists yet",
                skills - count("SELECT count(DISTINCT skill_slug) FROM career_skills"),
                skills,
                "career_skills is far thinner than job_role_skills, so common skills show zero careers.",
                "/admin/skills"));

        long jobRoles = count("SELECT count(*) FROM job_roles");
        gaps.add(new ContentGap(
                "Job roles with no salary",
                count("SELECT count(*) FROM job_roles WHERE salary_min_lpa IS NULL"),
                jobRoles,
                "These are excluded from every salary filter rather than counted as zero.",
                "/admin/job-roles"));

        gaps.add(new ContentGap(
                "Industries nothing links to",
                count("""
                        SELECT count(*) FROM industries i
                        WHERE NOT EXISTS (SELECT 1 FROM career_industries x WHERE x.industry_slug = i.slug)
                          AND NOT EXISTS (SELECT 1 FROM job_role_industries x WHERE x.industry_slug = i.slug)
                          AND NOT EXISTS (SELECT 1 FROM specialization_industries x WHERE x.industry_slug = i.slug)
                        """),
                count("SELECT count(*) FROM industries"),
                "An industry nothing points at is a row rather than an answer.",
                "/admin/industries"));

        gaps.removeIf(g -> g.affected() == 0);
        gaps.sort((a, b) -> Long.compare(b.affected(), a.affected()));
        return gaps;
    }

    /**
     * Created or edited since V115. Short by design at first: the seeded rows
     * have no timestamps, and this list fills as real edits happen.
     */
    @SuppressWarnings("unchecked")
    private List<RecentChange> recentChanges() {
        StringBuilder sql = new StringBuilder();
        for (String[] e : ENTITIES) {
            if (sql.length() > 0) sql.append(" UNION ALL ");
            // job_roles and the rest use `name`; careers, degrees and resources
            // use `title`.
            //
            // The ternary that used to be here read
            // `e[2].equals("resources") ? "title" : "title"` -- both branches
            // the same, so it tested nothing and only looked as though resources
            // were a special case. Sonar caught it as java:S3923. The output was
            // always correct; the code lied about why.
            String titleCol = switch (e[2]) {
                case "careers", "degrees", "resources" -> "title";
                default -> "name";
            };
            sql.append(String.format(
                    "SELECT '%s' AS entity, '%s' AS label, slug, %s AS title, "
                            + "COALESCE(updated_at, created_at) AS at, (updated_at IS NULL) AS is_new "
                            + "FROM %s WHERE created_at IS NOT NULL OR updated_at IS NOT NULL",
                    e[0], e[1], titleCol, e[2]));
        }
        sql.append(" ORDER BY at DESC LIMIT 8");

        List<Object[]> rows = em.createNativeQuery(sql.toString()).getResultList();
        List<RecentChange> out = new ArrayList<>();
        for (Object[] r : rows) {
            out.add(new RecentChange(
                    (String) r[0], (String) r[1], (String) r[2], (String) r[3],
                    toInstant(r[4]), Boolean.TRUE.equals(r[5])));
        }
        return out;
    }

    @SuppressWarnings("unchecked")
    private List<RecentUser> recentUsers() {
        List<Object[]> rows = em.createNativeQuery(
                "SELECT name, email, created_at FROM users ORDER BY created_at DESC LIMIT 5"
        ).getResultList();
        List<RecentUser> out = new ArrayList<>();
        for (Object[] r : rows) {
            out.add(new RecentUser((String) r[0], (String) r[1], toInstant(r[2])));
        }
        return out;
    }

    private long undatedRows() {
        long total = 0;
        for (String[] e : ENTITIES) {
            total += count("SELECT count(*) FROM " + e[2] + " WHERE created_at IS NULL AND updated_at IS NULL");
        }
        return total;
    }

    private long count(String sql) {
        Object result = em.createNativeQuery(sql).getSingleResult();
        return ((Number) result).longValue();
    }

    private static Instant toInstant(Object value) {
        if (value == null) return null;
        if (value instanceof Timestamp ts) return ts.toInstant();
        if (value instanceof Instant i) return i;
        if (value instanceof java.time.OffsetDateTime o) return o.toInstant();
        return null;
    }
}
