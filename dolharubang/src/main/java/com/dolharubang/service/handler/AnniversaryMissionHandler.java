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
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class AnniversaryMissionHandler {

    private final MemberMissionRepository memberMissionRepository;
    private final MemberRepository memberRepository;

    @EventListener
    @Transactional
    public void handleAnniversary(AnniversaryEvent event) {
        log.info("[AnniversaryMissionHandler] 이벤트 처리 시작. 회원 ID: {}, 입양일로부터 경과일: {}일",
            event.memberId(), event.daysSinceAdoption());

        try {
            Member member = memberRepository.findById(event.memberId())
                .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

            // 완료되지 않은 ANNIVERSARY 미션 전체 조회
            List<MemberMission> missions = memberMissionRepository
                .findByMemberAndMission_Condition_CategoryAndStatusNot(
                    member,
                    MissionCategory.ANNIVERSARY,
                    MissionStatusType.COMPLETED
                );
            log.info("완료되지 않은 ANNIVERSARY 미션 {}건 조회", missions.size());

            // 가장 작은 anniversaryDay 값을 가진 미션 찾기
            Optional<MemberMission> maxMissionOpt = missions.stream()
                .filter(mission ->
                    mission.getMission().getCondition().getDetails().get("anniversaryDay") != null
                )
                .min(Comparator.comparing(mission ->
                    (Integer) mission.getMission().getCondition().getDetails().get("anniversaryDay")
                ));

            if (maxMissionOpt.isPresent()) {
                MemberMission mission = maxMissionOpt.get();
                MissionCondition condition = mission.getMission().getCondition();
                Integer requiredDays = (Integer) condition.getDetails().get("anniversaryDay");
                log.info("가장 작은 anniversaryDay({}) 미션 선택: 미션 ID={}, 상태={}",
                    requiredDays, mission.getId(), mission.getStatus());

                // 미완료 미션 처리 로직
                if (requiredDays != null && event.daysSinceAdoption() == requiredDays) {
                    log.info("미션 완료 조건 충족! (입양일로부터 {}일)", requiredDays);
                    MissionProgressInfo progressInfo = mission.getProgressInfo();
                    progressInfo.setCurrentValue(requiredDays);
                    mission.setProgress(1.0);
                    mission.setStatus(MissionStatusType.COMPLETED);
                    mission.setAchievementDate(LocalDateTime.now());
                    memberMissionRepository.save(mission);
                    log.info("미션 완료 처리: 미션 ID={}", mission.getId());
                } else {
                    log.info("미션 완료 조건 불충족: 현재 경과일={}, 필요일={}",
                        event.daysSinceAdoption(), requiredDays);
                }
            } else {
                log.info("처리 가능한 미션 없음");
            }
        } catch (Exception e) {
            log.error("주년 미션 처리 중 오류 발생", e);
            throw e;
        } finally {
            log.info("[AnniversaryMissionHandler] 이벤트 처리 완료");
        }
    }
}
