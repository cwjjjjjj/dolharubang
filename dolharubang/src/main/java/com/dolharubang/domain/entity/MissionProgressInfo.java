package com.dolharubang.domain.entity;

import jakarta.persistence.Embeddable;
import java.time.LocalDate;
import java.time.LocalDateTime;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Embeddable
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class MissionProgressInfo {

    private int currentValue;
    private int streakCount;
    private int totalCount;
    private LocalDateTime lastUpdateDate;
    private String eventType;

    @Builder
    public MissionProgressInfo(int currentValue, String eventType) {
        this.currentValue = currentValue;
        this.eventType = eventType;
        this.streakCount = 1;
        this.totalCount = currentValue;
        this.lastUpdateDate = LocalDateTime.now();
    }

    public void update(int newValue, String eventType) {
        this.currentValue = newValue;
        this.eventType = eventType;
        this.totalCount += newValue;
        updateStreak(LocalDate.now());
    }

    private void updateStreak(LocalDate date) {
        if (lastUpdateDate == null) {
            streakCount = 1;
        } else {
            LocalDate lastDate = lastUpdateDate.toLocalDate();
            if (date.equals(lastDate)) {
                // 같은 날짜면 streakCount 유지
                return;
            } else if (date.minusDays(1).equals(lastDate)) {
                // 하루 차이나면 streakCount 증가
                streakCount++;
            } else {
                // 하루 이상 차이나면 리셋
                streakCount = 1;
            }
        }
        lastUpdateDate = date.atStartOfDay();
    }
}