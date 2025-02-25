package com.dolharubang.domain.dto.response;

import com.dolharubang.domain.entity.MemberMission;
import com.dolharubang.domain.entity.Mission;
import com.dolharubang.type.ConditionType;
import com.dolharubang.type.MissionCategory;
import com.dolharubang.type.MissionStatusType;
import com.dolharubang.type.RewardType;
import java.time.LocalDateTime;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class MemberMissionResDto {

    private Long id;
    private Long memberId;
    private Long missionId;
    private MissionStatusType status;
    private Double progress;
    private boolean isRewarded;
    private LocalDateTime achievementDate;
    private LocalDateTime rewardedAt;

    // 미션 정보
    private String missionName;
    private MissionCategory category;
    private ConditionType conditionType;
    private int requiredValue;
    private Integer currentValue;
    private Integer streakCount;

    // 보상 정보
    private RewardType rewardType;
    private int rewardQuantity;
    private String rewardItemNo;

    public static MemberMissionResDto fromEntity(MemberMission memberMission) {
        Mission mission = memberMission.getMission();
        return MemberMissionResDto.builder()
            .id(memberMission.getId())
            .memberId(memberMission.getMember().getMemberId())
            .missionId(mission.getId())
            .status(memberMission.getStatus())
            .progress(memberMission.getProgress())
            .isRewarded(memberMission.isRewarded())
            .achievementDate(memberMission.getAchievementDate())
            .rewardedAt(memberMission.getRewardedAt())
            // 미션 정보
            .missionName(mission.getName())
            .category(mission.getCondition().getCategory())
            .conditionType(mission.getCondition().getConditionType())
            .requiredValue(mission.getCondition().getRequiredValue())
            .currentValue(memberMission.getProgressInfo().getCurrentValue())
            .streakCount(memberMission.getProgressInfo().getStreakCount())
            // 보상 정보
            .rewardType(mission.getReward().getType())
            .rewardQuantity(mission.getReward().getQuantity())
            .rewardItemNo(mission.getReward().getItemNo())
            .build();
    }
}