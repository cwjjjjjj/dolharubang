package com.dolharubang.domain.entity;

import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import com.dolharubang.type.MissionStatusType;
import jakarta.persistence.Column;
import jakarta.persistence.Embedded;
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
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

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
    @OnDelete(action = OnDeleteAction.CASCADE)
    private Mission mission;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private MissionStatusType status;

    private LocalDateTime achievementDate;

    @Column(nullable = false)
    private Double progress;

    @Embedded
    private MissionProgressInfo progressInfo;

    private boolean isRewarded;
    private LocalDateTime rewardedAt;

    @Builder
    public MemberMission(Member member, Mission mission) {
        this.member = member;
        this.mission = mission;
        this.status = MissionStatusType.NOT_STARTED;
        this.progress = 0.0;
        this.isRewarded = false;
        this.progressInfo = new MissionProgressInfo();
    }

    // 진행도 업데이트를 위한 메서드
    public void updateProgress(int currentValue, String eventType) {
        if (status == MissionStatusType.COMPLETED) {
            throw new CustomException(ErrorCode.INVALID_MISSION_STATUS);
        }

        progressInfo.update(currentValue, eventType);
        double newProgress = mission.getCondition().calculateProgress(progressInfo);

        MissionStatusType newStatus = newProgress >= 1.0 ?
            MissionStatusType.COMPLETED : MissionStatusType.PROGRESSING;

        updateStatus(newStatus, newProgress);
    }

    public void updateStatus(MissionStatusType status, Double progress) {
        validateStatusTransition(this.status, status);
        validateProgress(progress);

        this.status = status;
        this.progress = progress;

        if (status == MissionStatusType.COMPLETED) {
            this.achievementDate = LocalDateTime.now();
        } else if (status == MissionStatusType.NOT_STARTED) {
            this.achievementDate = null;
            this.isRewarded = false;
            this.progress = 0.0;
            this.progressInfo = new MissionProgressInfo();
        }
    }

    private void validateStatusTransition(MissionStatusType from, MissionStatusType to) {
        if (mission.isDaily() && to == MissionStatusType.NOT_STARTED) {
            return;
        }
        if (from == MissionStatusType.COMPLETED && to != MissionStatusType.NOT_STARTED) {
            throw new CustomException(ErrorCode.INVALID_MISSION_STATUS);
        }
        if (isRewarded && to != MissionStatusType.COMPLETED) {
            throw new CustomException(ErrorCode.MEMBER_MISSION_ALREADY_REWARDED);
        }
    }

    private void validateProgress(Double progress) {
        if (progress < 0 || progress > 1) {
            throw new CustomException(ErrorCode.INVALID_MISSION_PROGRESS);
        }
    }

    public void markAsRewarded() {
        if (status != MissionStatusType.COMPLETED) {
            throw new CustomException(ErrorCode.INVALID_MISSION_STATUS);
        }
        if (isRewarded) {
            throw new CustomException(ErrorCode.MEMBER_MISSION_ALREADY_REWARDED);
        }
        this.isRewarded = true;
        this.rewardedAt = LocalDateTime.now();
    }

    public boolean canReceiveReward() {
        return status == MissionStatusType.COMPLETED && !isRewarded;
    }

    public void setProgress(Double progress) {
        this.progress = progress;
    }

    public void setStatus(MissionStatusType status) {
        this.status = status;
    }

    public void setAchievementDate(LocalDateTime achievementDate) {
        this.achievementDate = achievementDate;
    }
}
