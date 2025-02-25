package com.dolharubang.controller;

import com.dolharubang.domain.dto.request.MemberMissionProgressUpdateReqDto;
import com.dolharubang.domain.dto.response.MemberMissionResDto;
import com.dolharubang.service.MemberMissionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "Member Missions", description = "APIs for managing member missions")
@RestController
@RequestMapping("/api/v1/member-missions")
public class MemberMissionController {

    private final MemberMissionService memberMissionService;

    public MemberMissionController(MemberMissionService memberMissionService) {
        this.memberMissionService = memberMissionService;
    }

    @Operation(summary = "미션 진행 상태 업데이트")
    @PatchMapping("/{id}/progress")
    public ResponseEntity<MemberMissionResDto> updateMissionProgress(
        @PathVariable Long id,
        @Valid @RequestBody MemberMissionProgressUpdateReqDto requestDto) {
        return ResponseEntity.ok(memberMissionService.updateMissionProgress(id, requestDto));
    }

    @Operation(summary = "특정 회원 미션 보상 받기", description = "특정 회원이 미션을 보상받습니다.")
    @PostMapping("/{id}/reward")
    public ResponseEntity<MemberMissionResDto> claimReward(@PathVariable Long id) {
        MemberMissionResDto response = memberMissionService.claimReward(id);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "특정 회원 미션 모두 조회", description = "특정 회원의 모든 미션을 조회합니다.")
    @GetMapping("/{memberId}/missions")
    public ResponseEntity<List<MemberMissionResDto>> getMemberMissions(
        @PathVariable Long memberId) {
        List<MemberMissionResDto> missions = memberMissionService.getMemberMissions(memberId);
        return ResponseEntity.ok(missions);
    }

    @Operation(summary = "회원 미션 상세 조회", description = "회원 미션 ID를 통해 특정 회원 미션을 조회합니다.")
    @GetMapping("/{id}")
    public ResponseEntity<MemberMissionResDto> getMemberMission(@PathVariable Long id) {
        MemberMissionResDto response = memberMissionService.getMemberMission(id);
        return ResponseEntity.ok(response);
    }

}
