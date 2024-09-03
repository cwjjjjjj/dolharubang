package com.dolharubang.domain.dto.response;

import com.dolharubang.domain.entity.Schedule;
import java.time.LocalDateTime;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Builder
@Getter
@Setter
@ToString
public class ScheduleResDto {

    private Long id;
    private String contents;
    private LocalDateTime startScheduleDate;
    private LocalDateTime endScheduleDate;
    private Boolean isAlarm;
    private LocalDateTime alarmTime;
    private LocalDateTime createdAt;
    private LocalDateTime modifiedAt;

    public static ScheduleResDto fromEntity(Schedule schedule) {
        return ScheduleResDto.builder()
            .id(schedule.getId())
            .contents(schedule.getContents())
            .startScheduleDate(schedule.getStartScheduleDate())
            .endScheduleDate(schedule.getEndScheduleDate())
            .isAlarm(schedule.isAlarm())
            .alarmTime(schedule.getAlarmTime())
            .createdAt(schedule.getCreatedAt())
            .modifiedAt(schedule.getModifiedAt())
            .build();
    }
}
