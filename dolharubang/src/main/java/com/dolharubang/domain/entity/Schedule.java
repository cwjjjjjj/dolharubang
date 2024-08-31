package com.dolharubang.domain.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import java.time.LocalDateTime;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Schedule extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "schedule_id")
    private Long id;

    @ManyToOne
    @JoinColumn(name = "member_id")
    private Member member;

    private boolean isAlarm;

    private String contents;

    private LocalDateTime alarmTime;

    private LocalDateTime scheduleDate;

    @Builder
    public Schedule(Long id, Member member, boolean isAlarm, String contents,
        LocalDateTime alarmTime, LocalDateTime scheduleDate) {
        this.id = id;
        this.member = member;
        this.isAlarm = isAlarm;
        this.contents = contents;
        this.alarmTime = alarmTime;
        this.scheduleDate = scheduleDate;
    }

    public void update(Member member, String contents, LocalDateTime scheduleDate,
        Boolean isAlarm, LocalDateTime alarmTime) {
        this.member = member;
        this.contents = contents;
        this.scheduleDate = scheduleDate;
        this.isAlarm = isAlarm;
        this.alarmTime = alarmTime;
    }
}
