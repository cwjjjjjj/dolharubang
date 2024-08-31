package com.dolharubang.controller;

import com.dolharubang.domain.dto.request.ScheduleReqDto;
import com.dolharubang.domain.dto.response.ScheduleResDto;
import com.dolharubang.service.ScheduleService;
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
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "Schedules", description = "APIs for managing schedules")
@RestController
@RequestMapping("/api/v1/schedules")
public class SchedulesController {

    private final ScheduleService scheduleService;

    public SchedulesController(ScheduleService scheduleService) {
        this.scheduleService = scheduleService;
    }

    @Operation(summary = "스케줄 생성하기", description = "스케줄을 생성한다.")
    @PostMapping
    public ResponseEntity<ScheduleResDto> createSchedule(@RequestBody ScheduleReqDto requestDto) {
        ScheduleResDto response = scheduleService.createSchedule(requestDto);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "스케줄 수정하기", description = "schedule_id를 사용하여 스케줄을 수정한다.")
    @PatchMapping("/{id}")
    public ResponseEntity<ScheduleResDto> updateSchedule(
        @PathVariable Long id,
        @RequestBody ScheduleReqDto requestDto) {
        ScheduleResDto response = scheduleService.updateSchedule(id, requestDto);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "스케줄 단건 조회", description = "schedule_id를 통해 해당 스케줄의 단건 조회를 진행한다.")
    @GetMapping("/{id}")
    public ResponseEntity<ScheduleResDto> getSchedule(@PathVariable Long id) {
        ScheduleResDto response = scheduleService.getSchedule(id);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "스케줄 전체 조회", description = "스케줄 전체 조회를 진행한다.")
    @GetMapping
    public ResponseEntity<List<ScheduleResDto>> getSchedules(
        @RequestParam(required = false) Integer year,
        @RequestParam(required = false) Integer month,
        @RequestParam(required = false) Integer day,
        @RequestParam(required = false) String email) {

        List<ScheduleResDto> response = scheduleService.getSchedulesByCriteria(year, month, day,
            email);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "스케줄 삭제", description = "해당 schedule_id를 삭제한다.")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteSchedule(@PathVariable Long id) {
        scheduleService.deleteSchedule(id);
        return ResponseEntity.noContent().build();
    }
}
