package com.dolharubang.service.handler;

import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.MemberMission;
import com.dolharubang.domain.entity.MissionCondition;
import com.dolharubang.domain.entity.MissionProgressInfo;
import com.dolharubang.domain.event.AttendanceEvent;
import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import com.dolharubang.repository.AttendanceRepository;
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
public class AttendanceMissionHandler {

    private final MemberMissionRepository memberMissionRepository;
    private final MemberRepository memberRepository;
    private final AttendanceRepository attendanceRepository;

    @EventListener
    @Transactional
    public void handleAttendance(AttendanceEvent event) {
        Member member = memberRepository.findById(event.memberId())
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        List<MemberMission> missions = memberMissionRepository.findByMemberAndMission_Condition_Category(
            member,
            MissionCategory.ATTENDANCE
        );

        missions.forEach(mission -> {
            MissionCondition condition = mission.getMission().getCondition();
            MissionProgressInfo progressInfo = mission.getProgressInfo();
            LocalDate eventDate = event.date();

            switch (condition.getConditionType()) {
                case FIRST -> handleFirst(mission, progressInfo, eventDate);
                case CONTINUOUS -> handleContinuous(mission, progressInfo, eventDate);
                case CUMULATIVE -> handleCumulative(mission, progressInfo, eventDate);
            }

            updateMissionStatus(mission);
            memberMissionRepository.save(mission);
        });
    }

    private void handleFirst(MemberMission mission, MissionProgressInfo progressInfo,
        LocalDate eventDate) {
        int totalCount = attendanceRepository.countByMember(mission.getMember());
        progressInfo.setCurrentValue(totalCount);
        progressInfo.setLastUpdateDate(eventDate.atStartOfDay());
        mission.setProgress(totalCount >= 1 ? 1.0 : 0.0);
    }

    private void handleContinuous(MemberMission mission, MissionProgressInfo progressInfo,
        LocalDate eventDate) {
        LocalDate lastDate = progressInfo.getLastUpdateDate() != null
            ? progressInfo.getLastUpdateDate().toLocalDate()
            : null;

        if (lastDate == null) {
            // 최초 출석 → streakCount = 1
            progressInfo.setStreakCount(1);
        } else if (lastDate.plusDays(1).equals(eventDate)) {
            // 연속 출석 → streakCount 증가
            progressInfo.setStreakCount(progressInfo.getStreakCount() + 1);
        } else {
            // 연속 출석 아님 → streakCount 리셋
            progressInfo.setStreakCount(1);
        }

        progressInfo.setLastUpdateDate(eventDate.atStartOfDay());
        mission.setProgress(
            Math.min(1.0,
                (double) progressInfo.getStreakCount() /
                    mission.getMission().getCondition().getRequiredValue()
            )
        );
    }


    private void handleCumulative(MemberMission mission, MissionProgressInfo progressInfo,
        LocalDate eventDate) {
        // 누적 출석 횟수 증가
        int totalCount = attendanceRepository.countByMember(mission.getMember());
        progressInfo.setTotalCount(totalCount);

        progressInfo.setLastUpdateDate(eventDate.atStartOfDay());
        mission.setProgress(
            Math.min(1.0,
                (double) totalCount /
                    mission.getMission().getCondition().getRequiredValue()
            )
        );
    }

    private void updateMissionStatus(MemberMission mission) {
        if (mission.getProgress() >= 1.0 &&
            mission.getStatus() != MissionStatusType.COMPLETED
        ) {
            mission.setStatus(MissionStatusType.COMPLETED);
            mission.setAchievementDate(LocalDateTime.now());
        } else if (mission.getProgress() > 0) {
            mission.setStatus(MissionStatusType.PROGRESSING);
        }
    }
}
