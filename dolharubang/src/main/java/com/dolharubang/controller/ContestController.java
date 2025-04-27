package com.dolharubang.controller;

import com.dolharubang.domain.dto.request.ContestReqDto;
import com.dolharubang.domain.dto.response.ContestResDto;
import com.dolharubang.domain.entity.oauth.PrincipalDetails;
import com.dolharubang.service.ContestService;
import com.dolharubang.type.ContestFeedSortType;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
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

    @Operation(summary = "콘테스트 생성", description = "새로운 콘테스트를 생성합니다")
    @PostMapping
    public ResponseEntity<ContestResDto> createContest(
        @AuthenticationPrincipal PrincipalDetails principal,
        @RequestBody ContestReqDto reqDto) {
        Long memberId = principal.getMember().getMemberId();
        return ResponseEntity.ok(contestService.createContest(memberId, reqDto));
    }

    @Operation(summary = "멤버의 모든 콘테스트 조회", description = "특정 멤버의 모든 콘테스트를 조회합니다")
    @GetMapping("/{memberId}")
    public ResponseEntity<List<ContestResDto>> getMyAllContestProfile(
        @AuthenticationPrincipal PrincipalDetails principal) {
        Long memberId = principal.getMember().getMemberId();
        return ResponseEntity.ok(contestService.getMyAllContestProfiles(memberId));
    }

    @Operation(summary = "특정 콘테스트 조회", description = "멤버의 특정 콘테스트를 조회합니다")
    @GetMapping("/{memberId}/{contestId}")
    public ResponseEntity<ContestResDto> getContestProfile(
        @AuthenticationPrincipal PrincipalDetails principal,
        @PathVariable Long contestId) {
        Long memberId = principal.getMember().getMemberId();
        ContestResDto contestResDto = contestService.getContestProfile(memberId, contestId);
        return ResponseEntity.ok(contestResDto);
    }

    @Operation(summary = "콘테스트 공개 여부 수정", description = "콘테스트의 공개 여부를 수정합니다")
    @PatchMapping("/{contestId}/visibility")
    public ResponseEntity<ContestResDto> updateContestVisibility(
        @AuthenticationPrincipal PrincipalDetails principal,
        @PathVariable Long contestId,
        @RequestParam Boolean isPublic) {
        Long memberId = principal.getMember().getMemberId();
        return ResponseEntity.ok(
            contestService.updateContestVisibility(memberId, contestId, isPublic));
    }

    @Operation(summary = "콘테스트 삭제", description = "특정 콘테스트를 삭제합니다")
    @DeleteMapping("/{contestId}")
    public ResponseEntity<Void> deleteContest(
        @AuthenticationPrincipal PrincipalDetails principal,
        @PathVariable Long contestId) {
        Long memberId = principal.getMember().getMemberId();
        contestService.deleteContest(memberId, contestId);
        return ResponseEntity.noContent().build();
    }

    @Operation(summary = "콘테스트 피드 조회", description = "콘테스트 피드를 조회합니다. 추천순 또는 최신순으로 정렬 가능합니다")
    @GetMapping("/feed")
    public ResponseEntity<List<ContestResDto>> getFeedContests(
        @AuthenticationPrincipal PrincipalDetails principal,
        @Parameter(description = "마지막으로 본 콘테스트 ID (페이징용)")
        @RequestParam(required = false) Long lastContestId,
        @Parameter(description = "정렬 방식 (RECOMMENDED: 추천순, LATEST: 최신순)")
        @RequestParam(defaultValue = "RECOMMENDED") ContestFeedSortType contestFeedSortType,
        @Parameter(description = "한 번에 가져올 콘테스트 개수 (기본값: 16)")
        @RequestParam(defaultValue = "16") int size) {

        Long memberId = principal.getMember().getMemberId();
        return ResponseEntity.ok(
            contestService.getFeedContests(memberId, lastContestId, contestFeedSortType, size));
    }
}
