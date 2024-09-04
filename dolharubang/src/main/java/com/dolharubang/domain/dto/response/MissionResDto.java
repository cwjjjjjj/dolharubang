package com.dolharubang.domain.dto.response;


import com.dolharubang.domain.dto.common.ConditionDetail;
import com.dolharubang.domain.entity.Mission;
import com.dolharubang.type.MissionType;
import com.dolharubang.type.RewardType;
import java.time.LocalDateTime;
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
    private MissionType missionType;
    private boolean isHidden;
    private boolean isDaily;
    private ConditionDetail conditionDetail;
    private RewardType rewardType;
    private int rewardQuantity;
    private long rewardItemNo;
    private LocalDateTime createdAt;
    private LocalDateTime modifiedAt;

    public static MissionResDto fromEntity(Mission mission) {
        return MissionResDto.builder()
            .id(mission.getId())
            .name(mission.getName())
            .description(mission.getDescription())
            .missionType(mission.getMissionType())
            .conditionDetail(mission.getConditionDetail())
            .rewardType(mission.getRewardType())
            .rewardQuantity(mission.getRewardQuantity())
            .rewardItemNo(mission.getRewardItemNo())
            .isHidden(mission.isHidden())
            .isDaily(mission.isDaily())
            .createdAt(mission.getCreatedAt())
            .modifiedAt(mission.getModifiedAt())
            .build();
    }

}
