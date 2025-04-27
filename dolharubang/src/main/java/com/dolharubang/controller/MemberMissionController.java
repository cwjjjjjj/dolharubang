package com.dolharubang.controller;

import com.dolharubang.domain.dto.request.MemberMissionProgressUpdateReqDto;
import com.dolharubang.domain.dto.response.MemberMissionResDto;
import com.dolharubang.domain.entity.oauth.PrincipalDetails;
import com.dolharubang.service.MemberMissionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/member-missions")
@Tag(name = "Member Missions", description = "APIs for managing member missions")
public class MemberMissionController {

    private final MemberMissionService memberMissionService;

    public MemberMissionController(MemberMissionService memberMissionService) {
        this.memberMissionService = memberMissionService;
    }

    @Operation(summary = "미션 진행 상태 업데이트")
    @PatchMapping("/{id}/progress")
    public ResponseEntity<MemberMissionResDto> updateMissionProgress(
        @PathVariable Long id,
        @Valid @RequestBody MemberMissionProgressUpdateReqDto requestDto,
        @AuthenticationPrincipal PrincipalDetails principal) {

        Long memberId = principal.getMember().getMemberId();
        return ResponseEntity.ok(
            memberMissionService.updateMissionProgress(id, memberId, requestDto));
    }

    @Operation(summary = "미션 보상 받기")
    @PostMapping("/{id}/reward")
    public ResponseEntity<MemberMissionResDto> claimReward(
        @PathVariable Long id,
        @AuthenticationPrincipal PrincipalDetails principal) {

        Long memberId = principal.getMember().getMemberId();
        return ResponseEntity.ok(memberMissionService.claimReward(id, memberId));
    }

    @Operation(summary = "내 미션 전체 조회")
    @GetMapping
    public ResponseEntity<List<MemberMissionResDto>> getMyMissions(
        @AuthenticationPrincipal PrincipalDetails principal) {

        Long memberId = principal.getMember().getMemberId();
        return ResponseEntity.ok(memberMissionService.getMemberMissions(memberId));
    }

    @Operation(summary = "내 미션 상세 조회")
    @GetMapping("/{id}")
    public ResponseEntity<MemberMissionResDto> getMemberMission(
        @PathVariable Long id,
        @AuthenticationPrincipal PrincipalDetails principal) {

        Long memberId = principal.getMember().getMemberId();
        return ResponseEntity.ok(memberMissionService.getMemberMission(id, memberId));
    }
}
