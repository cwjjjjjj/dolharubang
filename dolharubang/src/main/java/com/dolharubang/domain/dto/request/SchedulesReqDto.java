package com.dolharubang.domain.dto.request;

import com.dolharubang.domain.entity.Schedules;
import java.time.LocalDateTime;
import lombok.Getter;

@Getter
public class SchedulesReqDto {

    private Long id;
    private String memberEmail;
    private String contents;
    private LocalDateTime scheduleDate;
    private Boolean isAlarm;
    private LocalDateTime alarmTime;

    public static Schedules toEntity(SchedulesReqDto dto) {
        return Schedules.builder()
            .id(dto.getId())
            .memberEmail(dto.getMemberEmail())
            .contents(dto.getContents())
            .scheduleDate(dto.getScheduleDate())
            .isAlarm(dto.getIsAlarm())
            .alarmTime(dto.getAlarmTime())
            .build();
    }
}