package com.dolharubang.controller;

import com.dolharubang.domain.dto.request.MemberMissionReqDto;
import com.dolharubang.domain.dto.response.MemberMissionResDto;
import com.dolharubang.service.MemberMissionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
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

    @Operation(summary = "새로운 회원 미션 생성", description = "새로운 회원 미션을 생성합니다.")
    @PostMapping
    public ResponseEntity<MemberMissionResDto> createMemberMission(
        @RequestBody MemberMissionReqDto requestDto) {
        MemberMissionResDto response = memberMissionService.createMemberMission(requestDto);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "기존 회원 미션 수정", description = "기존 회원 미션을 수정합니다.")
    @PatchMapping("/{id}")
    public ResponseEntity<MemberMissionResDto> updateMemberMission(
        @PathVariable Long id,
        @RequestBody MemberMissionReqDto requestDto) {
        MemberMissionResDto response = memberMissionService.updateMemberMission(id, requestDto);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "회원 미션 상세 조회", description = "회원 미션 ID를 통해 특정 회원 미션을 조회합니다.")
    @GetMapping("/{id}")
    public ResponseEntity<MemberMissionResDto> getMemberMission(@PathVariable Long id) {
        MemberMissionResDto response = memberMissionService.getMemberMission(id);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "모든 회원 미션 조회", description = "모든 회원 미션을 조회합니다.")
    @GetMapping
    public ResponseEntity<List<MemberMissionResDto>> getAllMemberMissions() {
        List<MemberMissionResDto> response = memberMissionService.getAllMemberMissions();
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "회원 미션 삭제", description = "회원 미션 ID를 통해 특정 회원 미션을 삭제합니다.")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteMemberMission(@PathVariable Long id) {
        memberMissionService.deleteMemberMission(id);
        return ResponseEntity.noContent().build();
    }
}
