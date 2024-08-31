package com.dolharubang.domain.dto.request;

import com.dolharubang.domain.entity.Schedule;
import java.time.LocalDateTime;
import lombok.Getter;

@Getter
public class ScheduleReqDto {

    private Long id;
    private String memberEmail;
    private String contents;
    private LocalDateTime scheduleDate;
    private Boolean isAlarm;
    private LocalDateTime alarmTime;

    public static Schedule toEntity(ScheduleReqDto dto) {
        return Schedule.builder()
            .id(dto.getId())
            .memberEmail(dto.getMemberEmail())
            .contents(dto.getContents())
            .scheduleDate(dto.getScheduleDate())
            .isAlarm(dto.getIsAlarm())
            .alarmTime(dto.getAlarmTime())
            .build();
    }
}