package com.dolharubang.domain.dto.request;

import com.dolharubang.domain.dto.common.ConditionDetail;
import com.dolharubang.domain.entity.Mission;
import com.dolharubang.type.MissionType;
import com.dolharubang.type.RewardType;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class MissionReqDto {

    private String name;
    private String description;
    private MissionType missionType;
    private boolean isHidden;
    private boolean isDaily;
    private ConditionDetail conditionDetail;
    private RewardType rewardType;
    private int rewardQuantity;
    private long rewardItemNo;

    public Mission toEntity() {
        return Mission.builder()
            .name(this.name)
            .description(this.description)
            .missionType(this.missionType)
            .conditionDetail(this.conditionDetail)
            .rewardType(this.rewardType)
            .rewardQuantity(this.rewardQuantity)
            .rewardItemNo(this.rewardItemNo)
            .isHidden(this.isHidden)
            .isDaily(this.isDaily)
            .build();
    }
}
