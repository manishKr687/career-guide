package com.careerguide.api.service;

import com.careerguide.api.dto.AdminGoalLineDto;
import com.careerguide.api.dto.GoalLineStationDto;
import com.careerguide.api.dto.GoalLineSummaryDto;
import com.careerguide.api.dto.SaveGoalLineRequest;
import com.careerguide.api.entity.GoalLine;
import com.careerguide.api.entity.GoalLineStation;
import com.careerguide.api.repository.GoalLineRepository;
import com.careerguide.api.repository.GoalLineStationRepository;
import com.careerguide.api.repository.UserGoalRepository;
import com.careerguide.api.web.NotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * Admin-set lines for My Career goals (V149).
 *
 * <p>A saved line is what new goals for that item start from. People who
 * already have the item as their goal keep their own copy; their page offers
 * the new line, because their goal's recorded source no longer matches.
 */
@Service
public class GoalLineAdminService {

    private final GoalLineRepository lines;
    private final GoalLineStationRepository lineStations;
    private final UserGoalRepository goals;
    private final GoalCatalog catalog;

    public GoalLineAdminService(GoalLineRepository lines, GoalLineStationRepository lineStations,
                                UserGoalRepository goals, GoalCatalog catalog) {
        this.lines = lines;
        this.lineStations = lineStations;
        this.goals = goals;
        this.catalog = catalog;
    }

    @Transactional(readOnly = true)
    public List<GoalLineSummaryDto> list() {
        return lines.findAllByOrderByUpdatedAtDesc().stream().map(l -> {
            String name;
            try {
                name = catalog.automatic(l.getGoalType(), l.getTargetSlug()).name();
            } catch (NotFoundException gone) {
                name = l.getTargetSlug() + " (removed)";
            }
            return new GoalLineSummaryDto(l.getGoalType(), l.getTargetSlug(), name,
                    lineStations.findAllByLineIdOrderByPositionAsc(l.getId()).size(), l.getVersion(), l.getUpdatedAt(),
                    goals.countByGoalTypeAndTargetSlug(l.getGoalType(), l.getTargetSlug()));
        }).toList();
    }

    /** Throws NotFoundException (404) when the item is not in the catalogue. */
    @Transactional(readOnly = true)
    public AdminGoalLineDto get(String type, String slug) {
        GoalCatalog.Blueprint auto = catalog.automatic(type, slug);
        List<GoalLineStationDto> automatic = auto.stations().stream()
                .map(s -> new GoalLineStationDto(s.name(), s.kind(), s.detail(), s.nextStep())).toList();
        long users = goals.countByGoalTypeAndTargetSlug(type, slug);
        return lines.findByGoalTypeAndTargetSlug(type, slug)
                .map(l -> new AdminGoalLineDto(type, slug, auto.name(), true, l.getVersion(), l.getUpdatedAt(), users,
                        lineStations.findAllByLineIdOrderByPositionAsc(l.getId()).stream()
                                .map(s -> new GoalLineStationDto(s.getName(), s.getKind(), s.getDetail(), s.getNextStep()))
                                .toList(),
                        automatic))
                .orElseGet(() -> new AdminGoalLineDto(type, slug, auto.name(), false, null, null, users, automatic, automatic));
    }

    /** Replaces the item's line; each save is a new version. */
    @Transactional
    public void save(String type, String slug, SaveGoalLineRequest request) {
        catalog.automatic(type, slug); // 404 for an item that isn't in the catalogue
        GoalLine line = lines.findByGoalTypeAndTargetSlug(type, slug).orElse(null);
        if (line == null) {
            line = new GoalLine(type, slug);
        } else {
            line.setVersion(line.getVersion() + 1);
        }
        line = lines.saveAndFlush(line);
        lineStations.deleteAllForLine(line.getId());
        int position = 0;
        for (GoalLineStationDto s : request.stations()) {
            String nextStep = s.nextStep() == null || s.nextStep().isBlank() ? null : s.nextStep().trim();
            lineStations.save(new GoalLineStation(line.getId(), position++, s.name().trim(), s.kind().trim(),
                    s.detail() == null ? "" : s.detail().trim(), nextStep));
        }
    }

    /** Removes the admin line, so the item goes back to the automatic one. */
    @Transactional
    public void reset(String type, String slug) {
        GoalLine line = lines.findByGoalTypeAndTargetSlug(type, slug)
                .orElseThrow(() -> new NotFoundException("No custom line for " + type + " " + slug));
        lines.delete(line);
    }
}
