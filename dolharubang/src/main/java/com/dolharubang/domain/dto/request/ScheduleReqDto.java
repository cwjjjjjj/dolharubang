package com.dolharubang.domain.dto.request;

import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.Schedule;
import java.time.LocalDateTime;
import lombok.Getter;

@Getter
public class ScheduleReqDto {

    private Long id;
    private Long memberId;
    private String contents;
    private LocalDateTime startScheduleDate;
    private LocalDateTime endScheduleDate;
    private Boolean isAlarm;
    private LocalDateTime alarmTime;

    public static Schedule toEntity(ScheduleReqDto dto, Member member) {
        return Schedule.builder()
            .id(dto.getId())
            .member(member)
            .contents(dto.getContents())
            .startScheduleDate(dto.getStartScheduleDate())
            .startScheduleDate(dto.getEndScheduleDate())
            .isAlarm(dto.getIsAlarm())
            .alarmTime(dto.getAlarmTime())
            .build();
    }
}