package com.careerguide.api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

/**
 * A field of study -- Physics, Computer Science, Nursing, Law. Added in V87.
 *
 * <p>Subject is the other half of a qualification. {@link Degree} answers
 * "what kind of qualification" (M.Sc, B.Tech, PhD); Subject answers "in what"
 * (Physics, Mechanical Engineering, Economics). Together they read as
 * "M.Sc (Physics)". Neither is stored as a combined row -- that product is
 * expressed by the link that selects them, so the pair cannot drift from its
 * parts and the title never has to be kept in sync with anything.
 *
 * <p>Degree.java's javadoc has always claimed the degrees table "isn't one row
 * per discipline". In practice 62 of its 143 rows had become exactly that --
 * B.A. (Economics), M.Sc Nursing, PhD in Engineering -- because there was
 * nowhere else for the subject to live. V87-V91 move those out to here.
 *
 * <p>Category lives on Subject, not on Degree, and this is not an arbitrary
 * placement: in the old product rows the same subject carried the same
 * category in every family it appeared in (bsc-agriculture, msc-agriculture
 * and phd-agricultural-sciences were all 'agriculture'), while the same
 * degree carried different categories depending on its subject. Category
 * describes the field, so it belongs to the field. Conversely `level`
 * (Undergraduate/Postgraduate/Doctoral) stays on Degree -- all 17 B.Sc
 * variants independently recorded 'Undergraduate', which is one fact about
 * the qualification, not seventeen about subjects.
 *
 * <p>Not every qualification takes one: see {@code Degree.requiresSubject}.
 * MBBS and BDS fuse the field into the qualification, and dual degrees like
 * BA LLB are two qualifications rather than one plus a subject.
 *
 * <p>Read-only in the public API and owned by nothing -- Subject has no
 * outbound relations at all. It is referenced by the link rows that pair it
 * with a degree, and those FKs are ON DELETE RESTRICT so a subject still in
 * use cannot be deleted out from under them.
 */
@Entity
@Table(name = "subjects")
public class Subject {

    @Id
    @Column(name = "slug", length = 64)
    private String slug;

    @Column(nullable = false, length = 160)
    private String title;

    @Column(nullable = false, columnDefinition = "text")
    private String description;

    @Column(nullable = false, length = 32)
    private String icon;

    // Non-null, unlike Degree.category: a field of study always sits in a
    // category, whereas a bare qualification type (Certificate, Diploma) may
    // not -- which is the whole reason Degree.category is nullable (V71).
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "category_slug", nullable = false)
    private Category category;

    // Public rather than protected -- see the equivalent note in Career.java.
    public Subject() {
    }

    public String getSlug() {
        return slug;
    }

    public String getTitle() {
        return title;
    }

    public String getDescription() {
        return description;
    }

    public String getIcon() {
        return icon;
    }

    public Category getCategory() {
        return category;
    }

    // --- Admin write path only; see the equivalent note in Career.java.

    public void setSlug(String slug) {
        this.slug = slug;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public void setIcon(String icon) {
        this.icon = icon;
    }

    public void setCategory(Category category) {
        this.category = category;
    }
}
