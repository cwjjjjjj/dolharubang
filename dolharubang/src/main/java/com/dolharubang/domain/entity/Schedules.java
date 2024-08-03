package com.dolharubang.domain.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import java.time.LocalDateTime;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Schedules {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "schedule_id")
    private Long id;

    private String memberEmail;

    private boolean isAlarm;

    private String contents;

    private LocalDateTime alarmTime;

    private LocalDateTime scheduleDate;

    private LocalDateTime createdAt;

    private LocalDateTime modifiedAt;

    @Builder
    public Schedules(Long id, String memberEmail, boolean isAlarm, String contents,
        LocalDateTime alarmTime, LocalDateTime scheduleDate,
        LocalDateTime createdAt, LocalDateTime modifiedAt) {
        this.id = id;
        this.memberEmail = memberEmail;
        this.isAlarm = isAlarm;
        this.contents = contents;
        this.alarmTime = alarmTime;
        this.scheduleDate = scheduleDate;
        this.createdAt = createdAt;
        this.modifiedAt = modifiedAt;
    }

    public void update(String memberEmail, String contents, LocalDateTime scheduleDate,
        Boolean isAlarm, LocalDateTime alarmTime) {
        this.memberEmail = memberEmail;
        this.contents = contents;
        this.scheduleDate = scheduleDate;
        this.isAlarm = isAlarm;
        this.alarmTime = alarmTime;
    }

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.modifiedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        this.modifiedAt = LocalDateTime.now();
    }
}
