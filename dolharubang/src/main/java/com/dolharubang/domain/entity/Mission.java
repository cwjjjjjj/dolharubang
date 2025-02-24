package com.dolharubang.domain.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Embedded;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Mission extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "mission_id")
    private Long id;

    @Column(name = "mission_name", nullable = false)
    private String name;

    @Column(name = "mission_description", nullable = false)
    private String description;

    @Column(nullable = false)
    private boolean isHidden;

    @Column(nullable = false)
    private boolean isDaily;

    @Embedded
    private MissionCondition condition;

    @Embedded
    private MissionReward reward;

    @Builder
    public Mission(String name, String description, boolean isHidden, boolean isDaily,
        MissionCondition condition, MissionReward reward) {
        this.name = name;
        this.description = description;
        this.isHidden = isHidden;
        this.isDaily = isDaily;
        this.condition = condition;
        this.reward = reward;
    }

    public void update(String name, String description, boolean isHidden, boolean isDaily,
        MissionCondition condition, MissionReward reward) {
        this.name = name;
        this.description = description;
        this.isHidden = isHidden;
        this.isDaily = isDaily;
        this.condition = condition;
        this.reward = reward;
    }
}
