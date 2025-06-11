package com.dolharubang.service.handler;

import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.MemberMission;
import com.dolharubang.domain.entity.MissionCondition;
import com.dolharubang.domain.entity.MissionProgressInfo;
import com.dolharubang.domain.event.AnniversaryEvent;
import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import com.dolharubang.repository.MemberMissionRepository;
import com.dolharubang.repository.MemberRepository;
import com.dolharubang.type.MissionCategory;
import com.dolharubang.type.MissionStatusType;
import jakarta.transaction.Transactional;
import java.time.LocalDateTime;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class AnniversaryMissionHandler {

    private final MemberMissionRepository memberMissionRepository;
    private final MemberRepository memberRepository;

    @EventListener
    @Transactional
    public void handleAnniversary(AnniversaryEvent event) {
        Member member = memberRepository.findById(event.memberId())
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        List<MemberMission> missions = memberMissionRepository
            .findByMemberAndMission_Condition_CategoryAndStatusNot(
                member,
                MissionCategory.ANNIVERSARY,
                MissionStatusType.COMPLETED
            );

        missions.forEach(mission -> {
            MissionCondition condition = mission.getMission().getCondition();
            Integer requiredDays = (Integer) condition.getDetails().get("days");

            if (requiredDays != null && event.daysSinceAdoption() == requiredDays) {
                MissionProgressInfo progressInfo = mission.getProgressInfo();
                progressInfo.setCurrentValue(1);
                mission.setProgress(1.0);
                updateMissionStatus(mission);
                memberMissionRepository.save(mission);
            }
        });
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
