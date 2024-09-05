package com.dolharubang.domain.entity;

import com.dolharubang.domain.dto.common.ConditionDetail;
import com.dolharubang.type.MissionType;
import com.dolharubang.type.RewardType;
import jakarta.persistence.Column;
import jakarta.persistence.Convert;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Lob;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class Mission extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "mission_id")
    private Long id;

    @Column(name = "mission_name", nullable = false)
    private String name;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private MissionType missionType;

    @Column(name = "mission_description", nullable = false)
    private String description;

    @Column(nullable = false)
    private boolean isHidden;

    @Column(nullable = false)
    private boolean isDaily;

    @Lob
    @Convert(converter = ConditionDetailConverter.class)
    @Column(nullable = false)
    private ConditionDetail conditionDetail;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private RewardType rewardType;

    private int rewardQuantity;

    private long rewardItemNo;


    public void updateMission(String name, String description, MissionType missionType,
        boolean isHidden, boolean isDaily, ConditionDetail conditionDetail, RewardType rewardType,
        int rewardQuantity, long rewardItemNo) {
        this.name = name;
        this.description = description;
        this.missionType = missionType;
        this.isHidden = isHidden;
        this.isDaily = isDaily;
        this.conditionDetail = conditionDetail;
        this.rewardType = rewardType;
        this.rewardQuantity = rewardQuantity;
        this.rewardItemNo = rewardItemNo;
    }

}
