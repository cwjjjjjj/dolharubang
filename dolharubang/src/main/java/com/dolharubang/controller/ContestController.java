package com.dolharubang.controller;

import com.dolharubang.domain.dto.request.ContestReqDto;
import com.dolharubang.domain.dto.response.ContestResDto;
import com.dolharubang.service.ContestService;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/contests")
@Tag(name = "Contests", description = "APIs for managing contests")
@RequiredArgsConstructor
public class ContestController {

    private final ContestService contestService;

    @PostMapping
    public ResponseEntity<ContestResDto> createContest(@RequestParam Long memberId,
        @RequestBody ContestReqDto reqDto) {
        return ResponseEntity.ok(contestService.createContest(memberId, reqDto));
    }

    @GetMapping("/{memberId}")
    public ResponseEntity<List<ContestResDto>> getMyAllContestProfile(@PathVariable Long memberId) {
        return ResponseEntity.ok(contestService.getMyAllContestProfiles(memberId));
    }

    @GetMapping("/{memberId}/{contestId}")
    public ResponseEntity<ContestResDto> getContestProfile(
        @PathVariable Long memberId,
        @PathVariable Long contestId) {
        ContestResDto contestResDto = contestService.getContestProfile(memberId, contestId);
        return ResponseEntity.ok(contestResDto);
    }

    @PatchMapping("/{memberId}/{contestId}/visibility")
    public ResponseEntity<ContestResDto> updateContestVisibility(@PathVariable Long memberId,
        @PathVariable Long contestId,
        @RequestParam Boolean isPublic) {
        return ResponseEntity.ok(
            contestService.updateContestVisibility(memberId, contestId, isPublic));
    }

    @DeleteMapping("/{memberId}/{contestId}")
    public ResponseEntity<Void> deleteContest(@PathVariable Long memberId,
        @PathVariable Long contestId) {
        contestService.deleteContest(memberId, contestId);
        return ResponseEntity.noContent().build();
    }

}
