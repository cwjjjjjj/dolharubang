package com.dolharubang.dolharubang.controller;

import com.dolharubang.dolharubang.domain.dto.request.SchedulesReqDto;
import com.dolharubang.dolharubang.domain.dto.response.SchedulesResDto;
import com.dolharubang.dolharubang.service.SchedulesService;
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

    private final SchedulesService schedulesService;

    public SchedulesController(SchedulesService schedulesService) {
        this.schedulesService = schedulesService;
    }

    @Operation(summary = "스케줄 생성하기", description = "스케줄을 생성한다.")
    @PostMapping
    public ResponseEntity<SchedulesResDto> createSchedule(@RequestBody SchedulesReqDto requestDto) {
        SchedulesResDto response = schedulesService.createSchedule(requestDto);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "스케줄 수정하기", description = "schedule_id를 사용하여 스케줄을 수정한다.")
    @PatchMapping("/{id}")
    public ResponseEntity<SchedulesResDto> updateSchedule(
        @PathVariable Long id,
        @RequestBody SchedulesReqDto requestDto) {
        SchedulesResDto response = schedulesService.updateSchedule(id, requestDto);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "스케줄 단건 조회", description = "schedule_id를 통해 해당 스케줄의 단건 조회를 진행한다.")
    @GetMapping("/{id}")
    public ResponseEntity<SchedulesResDto> getSchedule(@PathVariable Long id) {
        SchedulesResDto response = schedulesService.getSchedule(id);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "스케줄 전체 조회", description = "스케줄 전체 조회를 진행한다.")
    @GetMapping
    public ResponseEntity<List<SchedulesResDto>> getSchedules(
        @RequestParam(required = false) Integer year,
        @RequestParam(required = false) Integer month,
        @RequestParam(required = false) Integer day,
        @RequestParam(required = false) String email) {

        List<SchedulesResDto> response = schedulesService.getSchedulesByCriteria(year, month, day,
            email);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "스케줄 삭제", description = "해당 schedule_id를 삭제한다.")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteSchedule(@PathVariable Long id) {
        schedulesService.deleteSchedule(id);
        return ResponseEntity.noContent().build();
    }
}
