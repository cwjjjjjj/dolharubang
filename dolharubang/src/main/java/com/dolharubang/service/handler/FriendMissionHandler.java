package com.dolharubang.service.handler;

import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.MemberMission;
import com.dolharubang.domain.entity.MissionCondition;
import com.dolharubang.domain.entity.MissionProgressInfo;
import com.dolharubang.domain.event.FriendEvent;
import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import com.dolharubang.repository.MemberMissionRepository;
import com.dolharubang.repository.MemberRepository;
import com.dolharubang.type.MissionCategory;
import com.dolharubang.type.MissionStatusType;
import jakarta.transaction.Transactional;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class FriendMissionHandler {

    private final MemberMissionRepository memberMissionRepository;
    private final MemberRepository memberRepository;

    @EventListener
    @Transactional
    public void handleFriend(FriendEvent event) {
        Member member = memberRepository.findById(event.memberId())
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        List<MemberMission> missions = memberMissionRepository.findByMemberAndMission_Condition_CategoryAndStatusNot(
            member, MissionCategory.FRIEND, MissionStatusType.COMPLETED
        );

        missions.forEach(mission -> {
            MissionCondition condition = mission.getMission().getCondition();
            MissionProgressInfo progressInfo = mission.getProgressInfo();
            String requiredAction = (String) condition.getDetails().get("actionType");

            // 미션의 actionType과 이벤트의 actionType이 일치할 때만 진행
            if (event.actionType().name().equalsIgnoreCase(requiredAction)) {
                switch (condition.getConditionType()) {
                    case FIRST -> handleFirst(progressInfo, mission);
                    case CUMULATIVE ->
                        handleCumulative(progressInfo, mission, condition.getRequiredValue());
                    case CONTINUOUS -> handleContinuous(progressInfo, mission, event.date(),
                        condition.getRequiredValue());
                }
                updateMissionStatus(mission);
                memberMissionRepository.save(mission);
            }
        });
    }

    private void handleFirst(MissionProgressInfo progressInfo, MemberMission mission) {
        if (progressInfo.getCurrentValue() < 1) {
            progressInfo.setCurrentValue(1);
            mission.setProgress(1.0);
        }
    }

    private void handleCumulative(MissionProgressInfo progressInfo, MemberMission mission,
        int requiredValue) {
        int count = progressInfo.getTotalCount();
        progressInfo.setTotalCount(count + 1);
        mission.setProgress(Math.min(1.0, (double) progressInfo.getTotalCount() / requiredValue));
    }

    private void handleContinuous(MissionProgressInfo progressInfo, MemberMission mission,
        LocalDate eventDate, int requiredValue) {
        LocalDate lastDate = progressInfo.getLastUpdateDate() != null
            ? progressInfo.getLastUpdateDate().toLocalDate()
            : null;

        if (lastDate == null) {
            progressInfo.setStreakCount(1);
        } else if (lastDate.plusDays(1).equals(eventDate)) {
            progressInfo.setStreakCount(progressInfo.getStreakCount() + 1);
        } else {
            progressInfo.setStreakCount(1);
        }

        progressInfo.setLastUpdateDate(eventDate.atStartOfDay());
        mission.setProgress(Math.min(1.0, (double) progressInfo.getStreakCount() / requiredValue));
    }

    private void updateMissionStatus(MemberMission mission) {
        if (mission.getProgress() >= 1.0 && mission.getStatus() != MissionStatusType.COMPLETED) {
            mission.setStatus(MissionStatusType.COMPLETED);
            mission.setAchievementDate(LocalDateTime.now());
        } else if (mission.getProgress() > 0) {
            mission.setStatus(MissionStatusType.PROGRESSING);
        }
    }
}
