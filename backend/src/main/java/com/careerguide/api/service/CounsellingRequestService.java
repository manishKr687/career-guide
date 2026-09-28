package com.careerguide.api.service;

import com.careerguide.api.dto.CounsellingRequestDto;
import com.careerguide.api.dto.CounsellingRequestSubmission;
import com.careerguide.api.entity.CounsellingRequest;
import com.careerguide.api.mapper.DtoMapper;
import com.careerguide.api.repository.CounsellingRequestRepository;
import com.careerguide.api.web.NotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Set;

@Service
@Transactional(readOnly = true)
public class CounsellingRequestService {

    private static final Set<String> VALID_STATUSES = Set.of(
            CounsellingRequest.STATUS_PENDING,
            CounsellingRequest.STATUS_CONTACTED,
            CounsellingRequest.STATUS_COMPLETED
    );

    private final CounsellingRequestRepository repository;

    public CounsellingRequestService(CounsellingRequestRepository repository) {
        this.repository = repository;
    }

    /** Public submission from the booking form -- no auth, anyone can call this. */
    @Transactional
    public CounsellingRequestDto submit(CounsellingRequestSubmission submission) {
        CounsellingRequest request = new CounsellingRequest();
        request.setName(submission.name().trim());
        request.setEmail(submission.email().trim());
        request.setPhone(submission.phone().trim());
        request.setPreferredDate(submission.preferredDate());
        request.setPreferredTime(blankToNull(submission.preferredTime()));
        request.setStageSlug(blankToNull(submission.stageSlug()));
        request.setCareerSlug(blankToNull(submission.careerSlug()));
        request.setMessage(blankToNull(submission.message()));
        // status defaults to PENDING (set at field declaration in the entity)
        repository.save(request);
        return DtoMapper.toDto(request);
    }

    /** Admin inbox listing, newest first. */
    public List<CounsellingRequestDto> findAll() {
        return repository.findAllByOrderByCreatedAtDesc().stream().map(DtoMapper::toDto).toList();
    }

    @Transactional
    public CounsellingRequestDto updateStatus(Long id, String status) {
        if (!VALID_STATUSES.contains(status)) {
            throw new IllegalArgumentException("Invalid status: " + status + " (must be one of " + VALID_STATUSES + ")");
        }
        CounsellingRequest request = repository.findById(id)
                .orElseThrow(() -> new NotFoundException("Counselling request not found: " + id));
        request.setStatus(status);
        return DtoMapper.toDto(request);
    }

    @Transactional
    public void delete(Long id) {
        if (!repository.existsById(id)) {
            throw new NotFoundException("Counselling request not found: " + id);
        }
        repository.deleteById(id);
    }

    private static String blankToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
