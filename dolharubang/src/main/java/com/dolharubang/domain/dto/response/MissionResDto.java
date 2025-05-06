package com.dolharubang.domain.dto.response;


import com.dolharubang.domain.entity.Mission;
import com.dolharubang.type.ConditionType;
import com.dolharubang.type.MissionCategory;
import com.dolharubang.type.RewardType;
import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.LocalDateTime;
import java.util.Map;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Builder
@Getter
@Setter
@ToString
public class MissionResDto {

    private long id;
    private String name;
    private String description;

    @JsonProperty("isHidden")
    private boolean isHidden;

    @JsonProperty("isDaily")
    private boolean isDaily;

    // MissionCondition 관련 컬럼
    private MissionCategory category;
    private ConditionType conditionType;
    private int requiredValue;
    private Integer periodDays;
    private Map<String, Object> conditionDetails;

    // MissionReward 관련 컬럼
    private RewardType rewardType;
    private int rewardQuantity;
    private Long rewardItemNo;

    private LocalDateTime createdAt;
    private LocalDateTime modifiedAt;

    public static MissionResDto fromEntity(Mission mission) {
        return MissionResDto.builder()
            .id(mission.getId())
            .name(mission.getName())
            .description(mission.getDescription())
            .isHidden(mission.isHidden())
            .isDaily(mission.isDaily())

            // MissionCondition 매핑
            .category(mission.getCondition().getCategory())
            .conditionType(mission.getCondition().getConditionType())
            .requiredValue(mission.getCondition().getRequiredValue())
            .periodDays(mission.getCondition().getPeriodDays())
            .conditionDetails(mission.getCondition().getDetails())

            // MissionReward 매핑
            .rewardType(mission.getReward().getType())
            .rewardQuantity(mission.getReward().getQuantity())
            .rewardItemNo(mission.getReward().getItemNo())
            .createdAt(mission.getCreatedAt())
            .modifiedAt(mission.getModifiedAt())
            .build();
    }
}
