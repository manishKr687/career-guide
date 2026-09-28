package com.careerguide.api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OrderBy;
import jakarta.persistence.Table;

import java.util.ArrayList;
import java.util.List;

/**
 * A subject combination within a {@link Stream} -- PCM, PCB, PCMB. Added in
 * V97.
 *
 * <p>Sits between Stream and Career because "Science" is not a usable answer
 * on its own: it carries 29 of the catalog's 42 careers, and a student's
 * 11th-grade subject choice decides which of those they can actually enter.
 * B.Tech requires Mathematics, MBBS requires Biology, and the two sets barely
 * overlap. Showing a PCB student the engineering careers is not imprecision,
 * it is wrong.
 *
 * <p>Deliberately a child of Stream rather than four more Stream rows: PCM is
 * inside Science, not beside it, and {@code user_profiles.stream_slug} and
 * {@code stage_streams} both expect the four canonical streams as answers.
 *
 * <p>Optional per stream. Only Science has combinations today; Commerce,
 * Arts & Humanities and Vocational have none and remain leaves. Code reading
 * this relation must handle an empty list as the normal case, not an error.
 *
 * <p>Read-only, like {@link Stream} -- there is no admin write path for the
 * four canonical streams either.
 */
@Entity
@Table(name = "stream_combinations")
public class StreamCombination {

    @Id
    @Column(name = "slug", length = 64)
    private String slug;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "stream_slug", nullable = false)
    private Stream stream;

    @Column(nullable = false, length = 160)
    private String name;

    // "PCM" -- what students actually call it. The full name
    // ("Physics, Chemistry, Mathematics") is too long for a card heading.
    @Column(name = "short_name", nullable = false, length = 32)
    private String shortName;

    @Column(nullable = false, columnDefinition = "text")
    private String description;

    @Column(name = "sort_order", nullable = false)
    private Integer sortOrder = 0;

    // @OrderBy, not @OrderColumn: combination_careers has no sort_order
    // column and the ordering is not curated, same reasoning as
    // Stream.careers. Title sort keeps the rendered list stable.
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "combination_careers",
            joinColumns = @JoinColumn(name = "combination_slug"),
            inverseJoinColumns = @JoinColumn(name = "career_slug")
    )
    @OrderBy("title ASC")
    private List<Career> careers = new ArrayList<>();

    protected StreamCombination() {
        // JPA
    }

    public String getSlug() {
        return slug;
    }

    public Stream getStream() {
        return stream;
    }

    public String getName() {
        return name;
    }

    public String getShortName() {
        return shortName;
    }

    public String getDescription() {
        return description;
    }

    public Integer getSortOrder() {
        return sortOrder;
    }

    public List<Career> getCareers() {
        return careers;
    }
}
