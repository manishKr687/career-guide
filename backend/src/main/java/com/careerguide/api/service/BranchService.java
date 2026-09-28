package com.careerguide.api.service;

import com.careerguide.api.dto.BranchDto;
import com.careerguide.api.entity.Branch;
import com.careerguide.api.mapper.DtoMapper;
import com.careerguide.api.repository.BranchRepository;
import com.careerguide.api.web.NotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.List;

@Service
@Transactional(readOnly = true)
public class BranchService {

    private final BranchRepository branchRepository;

    public BranchService(BranchRepository branchRepository) {
        this.branchRepository = branchRepository;
    }

    public List<BranchDto> findAll(String category) {
        List<Branch> branches = StringUtils.hasText(category)
                ? branchRepository.findAllByCategorySlugOrderBySortOrderAsc(category)
                : branchRepository.findAllByOrderBySortOrderAsc();
        return branches.stream().map(DtoMapper::toDto).toList();
    }

    public BranchDto findBySlug(String slug) {
        Branch branch = branchRepository.findById(slug)
                .orElseThrow(() -> NotFoundException.forSlug("Branch", slug));
        return DtoMapper.toDto(branch);
    }
}
