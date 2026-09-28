package com.careerguide.api.entity;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OrderBy;
import jakarta.persistence.OrderColumn;
import jakarta.persistence.Table;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.util.ArrayList;
import java.util.List;
import java.time.Instant;

@Entity
@Table(name = "colleges")
public class College {

    @Id
    @Column(name = "slug", length = 64)
    private String slug;

    @Column(nullable = false, length = 200)
    private String name;

    @Column(nullable = false, length = 200)
    private String location;

    // Doubles as the spec's "college_type" -- see V53's migration comment
    // on why no separate column was added for that.
    @Column(nullable = false, length = 32)
    private String type;

    @Column(nullable = false)
    private Integer established;

    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(nullable = false, columnDefinition = "text[]")
    private List<String> tags = new ArrayList<>();

    @Column(nullable = false, columnDefinition = "text")
    private String description;

    // --- Added in V53 (College MVP) ---

    @Column(name = "ownership_type", nullable = false, length = 32)
    private String ownershipType;

    // Nullable -- most colleges in this catalog are autonomous
    // degree-granting institutes with no separate parent university. See
    // University.java's javadoc and V53's migration comment.
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "university_slug")
    private University university;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "state_slug", nullable = false)
    private State state;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "city_slug")
    private City city;

    @Column(length = 255)
    private String website;

    // V113: the college's place in an NIRF league table.
    //
    // All three move together -- the CHECK constraint refuses a rank without
    // its category and year -- because NIRF publishes a dozen separate tables
    // each year and "#2" means nothing without saying which one. IIT Madras is
    // 1st in Overall and 1st in Engineering; IISc is 2nd Overall and absent
    // from the Engineering table entirely.
    //
    // Unseeded for all 90: these are published figures, and recalling them
    // rather than reading them off the official tables would put unverified
    // numbers on a page students use to choose where to study.
    @Column(name = "nirf_rank")
    private Integer nirfRank;

    @Column(name = "nirf_category", length = 32)
    private String nirfCategory;

    @Column(name = "nirf_year")
    private Short nirfYear;

    @Column(nullable = false, length = 16)
    private String status;

    // The qualifications this college awards -- each a Degree plus optionally
    // the Subject it is offered in. Promoted from @ManyToMany in V103 for the
    // same reason as Career.education: a join table cannot carry the subject
    // column, and the old (college_slug, degree_slug) key allowed only one
    // row per degree, which breaks for a college offering M.Tech in a dozen
    // branches. The immediate driver was the 54 colleges that pointed at a
    // single "PhD in Engineering" product row.
    //
    // Distinct from careerOfferings below, which additionally names the
    // career the qualification leads to.
    @OneToMany(mappedBy = "college", fetch = FetchType.LAZY,
               cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("sortOrder ASC")
    private List<CollegeDegree> degrees = new ArrayList<>();

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "college_specializations",
            joinColumns = @JoinColumn(name = "college_slug"),
            inverseJoinColumns = @JoinColumn(name = "specialization_slug")
    )
    @OrderColumn(name = "sort_order")
    private List<Specialization> specializations = new ArrayList<>();

    // The inverse side of Career.relatedColleges -- same career_colleges
    // join table, read/written from the College side too, rather than a
    // second, parallel table. See V53's migration comment (point 2).
    // Unordered (no @OrderColumn -- sort_order there is meaningful from the
    // Career -> College direction only, same as any other mappedBy inverse
    // in this codebase).
    @ManyToMany(mappedBy = "relatedColleges", fetch = FetchType.LAZY)
    private List<Career> disciplines = new ArrayList<>();

    // Mirrors college.examSlugs from the frontend data model.
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "college_exams",
            joinColumns = @JoinColumn(name = "college_slug"),
            inverseJoinColumns = @JoinColumn(name = "exam_slug")
    )
    @OrderColumn(name = "sort_order")
    private List<Exam> exams = new ArrayList<>();

    // Added in V55 -- which degree(s) each of this college's career/
    // discipline offerings is actually awarded through. Admin-editable via
    // CollegeService.syncCareerOfferings -- cascade+orphanRemoval so
    // adding/removing entries in this list persists/deletes the
    // corresponding CollegeCareerDegree row. @OrderBy rather than
    // @OrderColumn since this is a real mapped entity with its own primary
    // key, not a plain @ManyToMany join-table collection.
    @OneToMany(mappedBy = "college", fetch = FetchType.LAZY, cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("sortOrder ASC")
    private List<CollegeCareerDegree> careerOfferings = new ArrayList<>();

    // Public rather than protected -- see the equivalent note in Career.java.
    // V115 added created_at/updated_at to this table; updated_at is
    // maintained by a database trigger, not by the services, so it is
    // mapped read-only -- Hibernate must never write it back.
    @Column(name = "updated_at", insertable = false, updatable = false)
    private Instant updatedAt;

    public College() {
    }

    public String getSlug() {
        return slug;
    }

    public String getName() {
        return name;
    }

    public String getLocation() {
        return location;
    }

    public String getType() {
        return type;
    }

    public Integer getEstablished() {
        return established;
    }

    public List<String> getTags() {
        return tags;
    }

    public String getDescription() {
        return description;
    }

    public String getOwnershipType() {
        return ownershipType;
    }

    public University getUniversity() {
        return university;
    }

    public State getState() {
        return state;
    }

    public City getCity() {
        return city;
    }

    public String getWebsite() {
        return website;
    }

    public Integer getNirfRank() {
        return nirfRank;
    }

    public String getNirfCategory() {
        return nirfCategory;
    }

    public Short getNirfYear() {
        return nirfYear;
    }

    public void setNirfRank(Integer nirfRank) {
        this.nirfRank = nirfRank;
    }

    public void setNirfCategory(String nirfCategory) {
        this.nirfCategory = nirfCategory;
    }

    public void setNirfYear(Short nirfYear) {
        this.nirfYear = nirfYear;
    }

    public String getStatus() {
        return status;
    }

    public List<CollegeDegree> getDegrees() {
        return degrees;
    }

    public List<Specialization> getSpecializations() {
        return specializations;
    }

    public List<Career> getDisciplines() {
        return disciplines;
    }

    public List<Exam> getExams() {
        return exams;
    }

    public List<CollegeCareerDegree> getCareerOfferings() {
        return careerOfferings;
    }

    // --- Admin write path only; see the equivalent note in Career.java.

    public void setSlug(String slug) {
        this.slug = slug;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public void setType(String type) {
        this.type = type;
    }

    public void setEstablished(Integer established) {
        this.established = established;
    }

    public void setTags(List<String> tags) {
        this.tags = tags;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public void setOwnershipType(String ownershipType) {
        this.ownershipType = ownershipType;
    }

    public void setUniversity(University university) {
        this.university = university;
    }

    public void setState(State state) {
        this.state = state;
    }

    public void setCity(City city) {
        this.city = city;
    }

    public void setWebsite(String website) {
        this.website = website;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    // No setDegrees(): orphanRemoval=true, so the list instance must not be
    // replaced. CollegeService.syncDegrees mutates it in place.

    public void setSpecializations(List<Specialization> specializations) {
        this.specializations = specializations;
    }

    public void setExams(List<Exam> exams) {
        this.exams = exams;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }
}
