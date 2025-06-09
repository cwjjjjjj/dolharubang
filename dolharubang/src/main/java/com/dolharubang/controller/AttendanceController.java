package com.dolharubang.controller;

import com.dolharubang.domain.entity.Member;
import com.dolharubang.service.AttendanceService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/attendances")
@Tag(name = "attendacnes", description = "APIs for managing attendances")
@RequiredArgsConstructor
public class AttendanceController {

    private final AttendanceService attendanceService;

    @Operation(summary = "출석 체크 요청", description = "출석 체크를 요청합니다.")
    @PostMapping
    public void checkIn(@AuthenticationPrincipal Member member) {
        attendanceService.checkIn(member);
    }
}
