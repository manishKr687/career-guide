package com.careerguide.api.service;

import com.careerguide.api.dto.CareerDto;
import com.careerguide.api.dto.CareerUpsertRequest;
import com.careerguide.api.entity.Career;
import com.careerguide.api.entity.Category;
import com.careerguide.api.repository.CareerRepository;
import com.careerguide.api.repository.CategoryRepository;
import com.careerguide.api.repository.CollegeRepository;
import com.careerguide.api.repository.DegreeRepository;
import com.careerguide.api.repository.ExamRepository;
import com.careerguide.api.repository.IndustryRepository;
import com.careerguide.api.repository.JobRoleRepository;
import com.careerguide.api.repository.SkillRepository;
import com.careerguide.api.repository.SpecializationRepository;
import com.careerguide.api.repository.StageRepository;
import com.careerguide.api.repository.SubjectRepository;
import com.careerguide.api.web.ConflictException;
import com.careerguide.api.web.NotFoundException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.ArgumentMatchers.isNull;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * Unit tests for {@link CareerService}, isolated from Spring/Hibernate/the
 * database entirely (plain Mockito mocks for every repository). Covers
 * sort-order assignment on create and unknown-slug/unknown-category error
 * handling. (The career_courses/course_careers bidirectional sync
 * regression test that used to live here was removed along with the
 * Courses feature -- see V43__remove_courses.sql.)
 */
@ExtendWith(MockitoExtension.class)
class CareerServiceTest {

    @Mock
    private CareerRepository careerRepository;
    @Mock
    private CategoryRepository categoryRepository;
    @Mock
    private ExamRepository examRepository;
    @Mock
    private StageRepository stageRepository;
    @Mock
    private SkillRepository skillRepository;
    @Mock
    private IndustryRepository industryRepository;
    @Mock
    private CollegeRepository collegeRepository;
    @Mock
    private SpecializationRepository specializationRepository;
    @Mock
    private JobRoleRepository jobRoleRepository;
    @Mock
    private DegreeRepository degreeRepository;
    @Mock
    private SubjectRepository subjectRepository;

    private CareerService careerService;

    @BeforeEach
    void setUp() {
        careerService = new CareerService(
                careerRepository, categoryRepository, examRepository, stageRepository,
                skillRepository, industryRepository, collegeRepository, specializationRepository, jobRoleRepository,
                degreeRepository, subjectRepository);
    }

    @Test
    void findAllNormalizesBlankFiltersToNull() {
        // careerWithCategory(...) does its own mock()/when()/thenReturn() --
        // it must be fully evaluated on its own line, before this outer
        // when(...) starts, or Mockito sees the inner when() call as an
        // interruption of this one's still-unfinished when().thenReturn()
        // chain and throws UnfinishedStubbingException.
        Career career = careerWithCategory("software-engineer", "engineering-technology");
        when(careerRepository.search(isNull(), isNull(), any(Pageable.class)))
                .thenReturn(new PageImpl<>(List.of(career)));

        Page<CareerDto> result = careerService.findAll("   ", "   ", Pageable.unpaged());

        assertThat(result.getContent()).extracting(CareerDto::slug).containsExactly("software-engineer");
        verify(careerRepository).search(isNull(), isNull(), any(Pageable.class));
    }

    @Test
    void findAllTrimsAndPassesThroughNonBlankFilters() {
        when(careerRepository.search(eq("engineering-technology"), eq("robot"), any(Pageable.class)))
                .thenReturn(new PageImpl<>(List.of()));

        careerService.findAll("engineering-technology", "  robot  ", Pageable.unpaged());

        verify(careerRepository).search(eq("engineering-technology"), eq("robot"), any(Pageable.class));
    }

    @Test
    void findBySlugReturnsDtoWhenFound() {
        // See findAllNormalizesBlankFiltersToNull for why this has to be a
        // separate statement before the when(...).thenReturn(...) below.
        Career career = careerWithCategory("software-engineer", "engineering-technology");
        when(careerRepository.findById("software-engineer"))
                .thenReturn(Optional.of(career));

        CareerDto dto = careerService.findBySlug("software-engineer");

        assertThat(dto.slug()).isEqualTo("software-engineer");
        assertThat(dto.categorySlug()).isEqualTo("engineering-technology");
    }

    @Test
    void findBySlugThrowsNotFoundForUnknownSlug() {
        when(careerRepository.findById("does-not-exist")).thenReturn(Optional.empty());

        assertThatThrownBy(() -> careerService.findBySlug("does-not-exist"))
                .isInstanceOf(NotFoundException.class);
    }

    @Test
    void createThrowsConflictWhenSlugAlreadyExists() {
        when(careerRepository.existsById("software-engineer")).thenReturn(true);

        assertThatThrownBy(() -> careerService.create(upsertRequest("software-engineer", "engineering-technology", null)))
                .isInstanceOf(ConflictException.class);

        verify(careerRepository, never()).save(any());
    }

    @Test
    void createThrowsIllegalArgumentForUnknownCategorySlug() {
        when(careerRepository.existsById("data-scientist")).thenReturn(false);
        when(categoryRepository.findById("not-a-real-category")).thenReturn(Optional.empty());

        assertThatThrownBy(() -> careerService.create(upsertRequest("data-scientist", "not-a-real-category", 1)))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("not-a-real-category");

        verify(careerRepository, never()).save(any());
    }

    @Test
    void createUsesGivenSortOrderWhenProvided() {
        when(careerRepository.existsById("data-scientist")).thenReturn(false);
        when(categoryRepository.findById("engineering-technology")).thenReturn(Optional.of(mock(Category.class)));

        careerService.create(upsertRequest("data-scientist", "engineering-technology", 7));

        ArgumentCaptor<Career> captor = ArgumentCaptor.forClass(Career.class);
        verify(careerRepository).save(captor.capture());
        assertThat(captor.getValue().getSortOrder()).isEqualTo(7);
    }

    @Test
    void createAssignsNextSortOrderWhenNotProvided() {
        Category category = mock(Category.class);
        when(category.getSlug()).thenReturn("engineering-technology");
        when(careerRepository.existsById("data-scientist")).thenReturn(false);
        when(categoryRepository.findById("engineering-technology")).thenReturn(Optional.of(category));

        Career existingHighest = mock(Career.class);
        when(existingHighest.getSortOrder()).thenReturn(4);
        when(careerRepository.findAllByCategorySlugOrderBySortOrderAsc("engineering-technology"))
                .thenReturn(List.of(existingHighest));

        careerService.create(upsertRequest("data-scientist", "engineering-technology", null));

        ArgumentCaptor<Career> captor = ArgumentCaptor.forClass(Career.class);
        verify(careerRepository).save(captor.capture());
        assertThat(captor.getValue().getSortOrder()).isEqualTo(5);
    }

    @Test
    void createAssignsSortOrderZeroWhenCategoryHasNoExistingCareers() {
        Category category = mock(Category.class);
        when(category.getSlug()).thenReturn("engineering-technology");
        when(careerRepository.existsById("data-scientist")).thenReturn(false);
        when(categoryRepository.findById("engineering-technology")).thenReturn(Optional.of(category));
        when(careerRepository.findAllByCategorySlugOrderBySortOrderAsc("engineering-technology"))
                .thenReturn(List.of());

        careerService.create(upsertRequest("data-scientist", "engineering-technology", null));

        ArgumentCaptor<Career> captor = ArgumentCaptor.forClass(Career.class);
        verify(careerRepository).save(captor.capture());
        assertThat(captor.getValue().getSortOrder()).isEqualTo(0);
    }

    @Test
    void updateThrowsNotFoundForUnknownSlug() {
        when(careerRepository.findById("does-not-exist")).thenReturn(Optional.empty());

        assertThatThrownBy(() -> careerService.update("does-not-exist", upsertRequest("does-not-exist", "engineering-technology", 1)))
                .isInstanceOf(NotFoundException.class);
    }

    @Test
    void deleteThrowsNotFoundWhenCareerDoesNotExist() {
        when(careerRepository.existsById("does-not-exist")).thenReturn(false);

        assertThatThrownBy(() -> careerService.delete("does-not-exist"))
                .isInstanceOf(NotFoundException.class);

        verify(careerRepository, never()).deleteById(anyString());
    }

    @Test
    void deleteRemovesExistingCareer() {
        when(careerRepository.existsById("software-engineer")).thenReturn(true);

        careerService.delete("software-engineer");

        verify(careerRepository).deleteById("software-engineer");
    }

    private static Career careerWithCategory(String slug, String categorySlug) {
        Category category = mock(Category.class);
        when(category.getSlug()).thenReturn(categorySlug);
        Career career = new Career();
        career.setSlug(slug);
        career.setCategory(category);
        return career;
    }

    private static CareerUpsertRequest upsertRequest(String slug, String categorySlug, Integer sortOrder) {
        return new CareerUpsertRequest(
                slug,
                "Title",
                categorySlug,
                "Tagline",
                "High",
                "Typical work",
                new BigDecimal("5"), new BigDecimal("10"),
                null,
                null,
                null,
                "icon-name",
                "Description",
                sortOrder,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null
        );
    }
}
