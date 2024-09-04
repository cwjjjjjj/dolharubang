package com.dolharubang.domain.entity;

import com.dolharubang.type.MissionStatusType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import java.time.LocalDateTime;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class MemberMission extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "member_mission_id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "mission_id", nullable = false)
    private Mission mission;

    @Enumerated(EnumType.STRING)
    @Column(nullable = true)
    private MissionStatusType status;

    private LocalDateTime achievementDate;

    @Column(nullable = false)
    private Double progress;

    @Builder
    public MemberMission(Member member, Mission mission, MissionStatusType status,
        Double progress) {
        this.member = member;
        this.mission = mission;
        this.status = status;
        this.progress = progress;
    }

    public void updateStatus(MissionStatusType status, Double progress) {
        this.status = status;
        this.progress = progress;

        if (status == MissionStatusType.COMPLETED) {
            this.achievementDate = LocalDateTime.now();
        } else if (status == MissionStatusType.NOT_STARTED) {
            this.achievementDate = null;
        }
    }
}
