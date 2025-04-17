package com.dolharubang.domain.dto.response;

import com.dolharubang.domain.entity.MemberMission;
import com.dolharubang.domain.entity.Mission;
import com.dolharubang.mongo.entity.Item;
import com.dolharubang.mongo.service.ItemService;
import com.dolharubang.type.RewardType;
import java.time.LocalDateTime;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class MemberMissionResDto {

    private boolean isRewarded;
    private LocalDateTime rewardedAt;

    // 미션 정보
    private String missionName;
    private String missionDescription;

    // 보상 정보
    private String rewardName;
    private String rewardImageUrl;
    private int rewardQuantity;

    public static MemberMissionResDto fromEntity(MemberMission memberMission,
        ItemService itemService) {
        Mission mission = memberMission.getMission();

        String rewardName = "SAND";
        String rewardImageUrl = "SAND_IMG";

        if (mission.getReward().getType() == RewardType.ITEM) {
            Item item = itemService.findByItemId(mission.getReward().getItemNo());
            if (item != null) {
                rewardName = item.getItemName();
                rewardImageUrl = item.getImageUrl();
            }
        }

        return MemberMissionResDto.builder()
            .isRewarded(memberMission.isRewarded())
            .rewardedAt(memberMission.getRewardedAt())
            // 미션 정보
            .missionName(mission.getName())
            .missionDescription(mission.getDescription())
            // 보상 정보
            .rewardQuantity(mission.getReward().getQuantity())
            .rewardName(rewardName)
            .rewardImageUrl(rewardImageUrl)
            .build();
    }
}
