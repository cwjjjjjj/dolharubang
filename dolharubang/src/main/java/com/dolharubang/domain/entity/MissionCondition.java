package com.dolharubang.domain.entity;

import com.dolharubang.type.ConditionType;
import com.dolharubang.type.MissionCategory;
import jakarta.persistence.Column;
import jakarta.persistence.Convert;
import jakarta.persistence.Embeddable;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import java.util.HashMap;
import java.util.Map;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Embeddable
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class MissionCondition {

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private MissionCategory category;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ConditionType conditionType;

    @Column(nullable = false)
    private int requiredValue;

    // 연속성이나 누적을 체크해야 하는 미션에서는 해당 값이 필요하지만, 최초 1회 같은 경우 기간 제한이 필요 없기 때문에 Integer을 사용해 null을 사용할 수 있게 함.
    private Integer periodDays;

    @Convert(converter = ConditionDetailsConverter.class)
    @Column(nullable = false)
    private Map<String, Object> details;

    @Builder
    public MissionCondition(MissionCategory category, ConditionType conditionType,
        int requiredValue, Integer periodDays, Map<String, Object> details) {
        this.category = category;
        this.conditionType = conditionType;
        this.requiredValue = requiredValue;
        this.periodDays = periodDays;
        this.details = details != null ? details : new HashMap<>();
    }

    public double calculateProgress(MissionProgressInfo progressInfo) {
        return switch (conditionType) {
            case CONTINUOUS -> calculateContinuousProgress(progressInfo);
            case CUMULATIVE -> calculateCumulativeProgress(progressInfo);
            case FIRST -> progressInfo.getCurrentValue() >= 1 ? 1.0 : 0.0;
            case SPECIFIC_EVENT -> calculateSpecificEventProgress(progressInfo);
        };
    }

    private double calculateContinuousProgress(MissionProgressInfo progressInfo) {
        return Math.min(1.0, (double) progressInfo.getStreakCount() / requiredValue);
    }

    private double calculateCumulativeProgress(MissionProgressInfo progressInfo) {
        return Math.min(1.0, (double) progressInfo.getTotalCount() / requiredValue);
    }

    private double calculateSpecificEventProgress(MissionProgressInfo progressInfo) {
        if (details == null ||
            !progressInfo.getEventType().equals(details.get("specificEvent"))) {
            return 0.0;
        }
        return progressInfo.getCurrentValue() >= requiredValue ? 1.0 : 0.0;
    }
}