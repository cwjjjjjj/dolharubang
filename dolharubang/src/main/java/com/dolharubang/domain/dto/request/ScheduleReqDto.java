package com.dolharubang.domain.dto.request;

import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.Schedule;
import java.time.LocalDateTime;
import lombok.Getter;

@Getter
public class ScheduleReqDto {

    private String contents;
    private LocalDateTime startScheduleDate;
    private LocalDateTime endScheduleDate;
    private Boolean isAlarm;
    private LocalDateTime alarmTime;

    public static Schedule toEntity(ScheduleReqDto dto, Member member) {
        return Schedule.builder()
            .member(member)
            .contents(dto.getContents())
            .startScheduleDate(dto.getStartScheduleDate())
            .endScheduleDate(dto.getEndScheduleDate())
            .isAlarm(dto.getIsAlarm())
            .alarmTime(dto.getAlarmTime())
            .build();
    }
}
