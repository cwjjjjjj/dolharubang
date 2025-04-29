package com.dolharubang.controller;

import com.dolharubang.domain.dto.request.ScheduleReqDto;
import com.dolharubang.domain.dto.response.ScheduleResDto;
import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.oauth.PrincipalDetails;
import com.dolharubang.service.ScheduleService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
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

@Tag(name = "Schedules", description = "APIs for managing schedules")
@RestController
@RequestMapping("/api/v1/schedules")
public class ScheduleController {

    private final ScheduleService scheduleService;

    public ScheduleController(ScheduleService scheduleService) {
        this.scheduleService = scheduleService;
    }

    @Operation(summary = "스케줄 생성하기", description = "스케줄을 생성한다.")
    @PostMapping
    public ResponseEntity<?> createSchedule(
        @RequestBody ScheduleReqDto requestDto,
        @AuthenticationPrincipal PrincipalDetails principal) {

        if (principal == null) {
            return ResponseEntity
                .status(HttpStatus.UNAUTHORIZED)
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of("code", "UNAUTHORIZED", "message", "인증안댐"));
        }

        Member member = principal.getMember();
        ScheduleResDto response = scheduleService.createSchedule(requestDto, member);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "스케줄 수정하기", description = "schedule_id를 사용하여 스케줄을 수정한다.")
    @PatchMapping("/{id}")
    public ResponseEntity<?> updateSchedule(
        @PathVariable Long id,
        @RequestBody ScheduleReqDto requestDto,
        @AuthenticationPrincipal PrincipalDetails principal) {

        if (principal == null) {
            return ResponseEntity
                .status(HttpStatus.UNAUTHORIZED)
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of("code", "UNAUTHORIZED", "message", "인증안댐"));
        }

        Member member = principal.getMember();
        ScheduleResDto response = scheduleService.updateSchedule(id, requestDto, member);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "스케줄 단건 조회", description = "schedule_id를 통해 해당 스케줄의 단건 조회를 진행한다.")
    @GetMapping("/{id}")
    public ResponseEntity<ScheduleResDto> getSchedule(@PathVariable Long id) {
        ScheduleResDto response = scheduleService.getSchedule(id);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "스케줄 조회", description = "연도, 월, 일 기준으로 나의 스케줄을 조회한다.")
    @GetMapping
    public ResponseEntity<?> getSchedules(
        @RequestParam(required = false) Integer year,
        @RequestParam(required = false) Integer month,
        @RequestParam(required = false) Integer day,
        @AuthenticationPrincipal PrincipalDetails principal) {

        if (principal == null) {
            return ResponseEntity
                .status(HttpStatus.UNAUTHORIZED)
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of("code", "UNAUTHORIZED", "message", "인증안댐"));
        }

        Long memberId = principal.getMember().getMemberId();
        List<ScheduleResDto> response = scheduleService.getSchedulesByCriteria(year, month, day,
            memberId);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "스케줄 삭제", description = "해당 schedule_id를 삭제한다.")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteSchedule(@PathVariable Long id) {
        scheduleService.deleteSchedule(id);
        return ResponseEntity.noContent().build();
    }
}
