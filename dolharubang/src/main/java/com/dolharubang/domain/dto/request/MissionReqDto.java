package com.dolharubang.domain.dto.request;

import com.dolharubang.domain.entity.Mission;
import com.dolharubang.domain.entity.MissionCondition;
import com.dolharubang.domain.entity.MissionReward;
import com.dolharubang.type.ConditionType;
import com.dolharubang.type.MissionCategory;
import com.dolharubang.type.RewardType;
import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.HashMap;
import java.util.Map;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class MissionReqDto {

    private String name;
    private String description;

    @JsonProperty("isHidden")
    private boolean isHidden;

    @JsonProperty("isDaily")
    private boolean isDaily;

    // MissionCondition 관련
    private MissionCategory category;
    private ConditionType conditionType;
    private int requiredValue;
    private Integer periodDays;
    private Map<String, Object> details;

    // MissionReward 관련
    private RewardType rewardType;
    private int rewardQuantity;
    private Long rewardItemNo;

    public Mission toEntity() {
        return Mission.builder()
            .name(this.name)
            .description(this.description)
            .isHidden(this.isHidden)
            .isDaily(this.isDaily)
            .condition(MissionCondition.builder()
                .category(this.category)
                .conditionType(this.conditionType)
                .requiredValue(this.requiredValue)
                .periodDays(this.periodDays)
                .details(this.details != null ? this.details : new HashMap<>())
                .build())
            .reward(MissionReward.builder()
                .type(this.rewardType)
                .quantity(this.rewardQuantity)
                .itemNo(this.rewardItemNo)
                .build())
            .build();
    }
}