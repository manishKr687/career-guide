package com.careerguide.api.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OrderBy;
import jakarta.persistence.Table;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

// Added in V29 -- see the Data Model Roadmap doc's "Spec v1.0 Match" tab.
// Read-only, minimal (slug/name/description): only the 4 canonical
// After-12th streams are seeded so far.
@Entity
@Table(name = "streams")
public class Stream {

    @Id
    @Column(name = "slug", length = 64)
    private String slug;

    @Column(nullable = false, length = 160)
    private String name;

    @Column(columnDefinition = "text")
    private String description;

    // stage_streams has no sort_order column (only 4 streams exist, and
    // which stage they belong to isn't curated ordering) -- a plain Set,
    // same reasoning as Career.relatedSkills/relatedIndustries.
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "stage_streams",
            joinColumns = @JoinColumn(name = "stream_slug"),
            inverseJoinColumns = @JoinColumn(name = "stage_slug")
    )
    private Set<Stage> stages = new HashSet<>();

    // The careers this stream is the normal route into -- seeded in V92, see
    // that migration for why it is "primary route" rather than "everything
    // technically permitted". The table has existed since V29 but was never
    // populated and never mapped here, so nothing could read it.
    //
    // @OrderBy rather than @OrderColumn: stream_careers has no sort_order
    // column and the ordering isn't curated, same reasoning as `stages`
    // above. Sorting by title keeps the rendered list stable -- an unordered
    // Set would let Postgres return the rows in any order between requests.
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "stream_careers",
            joinColumns = @JoinColumn(name = "stream_slug"),
            inverseJoinColumns = @JoinColumn(name = "career_slug")
    )
    @OrderBy("title ASC")
    private List<Career> careers = new ArrayList<>();

    // Subject combinations within this stream -- PCM/PCB/PCMB for Science
    // (V97). Empty for Commerce, Arts & Humanities and Vocational, which have
    // no standard named combinations: an empty list is the normal case here,
    // not a missing-data condition.
    //
    // Read-only and not cascaded: combinations are seeded, like the streams
    // themselves.
    @OneToMany(mappedBy = "stream", fetch = FetchType.LAZY)
    @OrderBy("sortOrder ASC")
    private List<StreamCombination> combinations = new ArrayList<>();

    protected Stream() {
        // JPA
    }

    public String getSlug() {
        return slug;
    }

    public String getName() {
        return name;
    }

    public String getDescription() {
        return description;
    }

    public Set<Stage> getStages() {
        return stages;
    }

    public List<Career> getCareers() {
        return careers;
    }

    public List<StreamCombination> getCombinations() {
        return combinations;
    }
}
