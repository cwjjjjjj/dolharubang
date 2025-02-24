package com.dolharubang.service;

import com.dolharubang.domain.entity.MemberMission;
import com.dolharubang.repository.MemberMissionRepository;
import com.dolharubang.type.MissionStatusType;
import java.time.LocalDateTime;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class MemberMissionScheduler {

    private static final Logger logger = LoggerFactory.getLogger(MemberMissionScheduler.class);
    private final MemberMissionRepository memberMissionRepository;

    public MemberMissionScheduler(MemberMissionRepository memberMissionRepository) {
        this.memberMissionRepository = memberMissionRepository;
    }

    @Scheduled(cron = "0 0 0 * * ?") // 매일 자정에 실행
//    @Scheduled(cron = "0 * * * * ?")  // 매 분 0초에 실행
    @Transactional
    public void resetDailyMissions() {
        List<MemberMission> dailyMissions = memberMissionRepository.findDailyMissions();

        for (MemberMission memberMission : dailyMissions) {
            memberMission.updateStatus(MissionStatusType.NOT_STARTED, 0.0);
        }
        logger.info("{} - 데일리 미션 초기화", LocalDateTime.now());
    }
}
