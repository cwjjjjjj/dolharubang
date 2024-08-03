package com.dolharubang.dolharubang.domain.dto.response;

import com.dolharubang.dolharubang.domain.entity.Schedules;
import java.time.LocalDateTime;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Builder
@Getter
@Setter
@ToString
public class SchedulesResDto {

    private Long id;
    private String memberEmail;
    private String contents;
    private LocalDateTime scheduleDate;
    private Boolean isAlarm;
    private LocalDateTime alarmTime;
    private LocalDateTime createdAt;
    private LocalDateTime modifiedAt;

    public static SchedulesResDto fromEntity(Schedules schedules) {
        return SchedulesResDto.builder()
            .id(schedules.getId())
            .memberEmail(schedules.getMemberEmail())
            .contents(schedules.getContents())
            .scheduleDate(schedules.getScheduleDate())
            .isAlarm(schedules.isAlarm())
            .alarmTime(schedules.getAlarmTime())
            .createdAt(schedules.getCreatedAt())
            .modifiedAt(schedules.getModifiedAt())
            .build();
    }
}