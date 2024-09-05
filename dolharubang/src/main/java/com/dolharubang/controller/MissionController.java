package com.dolharubang.controller;

import com.dolharubang.domain.dto.request.MissionReqDto;
import com.dolharubang.domain.dto.response.MissionResDto;
import com.dolharubang.domain.entity.Mission;
import com.dolharubang.service.MissionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "Missions", description = "APIs for managing missions")
@RestController
@RequestMapping("/api/v1/missions")
public class MissionController {

    private final MissionService missionService;

    public MissionController(MissionService missionService) {
        this.missionService = missionService;
    }

    @Operation(summary = "새로운 미션 생성", description = "새로운 미션을 생성합니다.")
    @PostMapping
    public ResponseEntity<MissionResDto> createMission(@RequestBody MissionReqDto requestDto) {
        MissionResDto response = missionService.createMission(requestDto);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "기존 미션 수정", description = "기존에 있던 미션을 수정합니다.")
    @PatchMapping("/{id}")
    public ResponseEntity<MissionResDto> updateMission(
        @PathVariable Long id,
        @RequestBody MissionReqDto requestDto) {
        MissionResDto response = missionService.updateMission(id, requestDto);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "상세 미션 검색", description = "mission_id를 통해 미션을 검색합니다.")
    @GetMapping("/{id}")
    public ResponseEntity<MissionResDto> getMission(@PathVariable Long id) {
        MissionResDto response = missionService.getMission(id);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "할당 받지 못한 미션 검색", description = "특정 회원이 할당 받지 못한 미션을 가져옵니다.")
    @GetMapping("/unassigned-missions")
    public ResponseEntity<List<Mission>> getUnassignedMissions(@RequestParam Long memberId) {
        List<Mission> unassignedMissions = missionService.getUnassignedMissionsForMember(memberId);
        return ResponseEntity.ok(unassignedMissions);
    }
}
