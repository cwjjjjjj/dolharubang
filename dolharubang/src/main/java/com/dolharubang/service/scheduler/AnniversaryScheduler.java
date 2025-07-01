package com.dolharubang.service.scheduler;

import com.dolharubang.domain.entity.Stone;
import com.dolharubang.domain.event.AnniversaryEvent;
import com.dolharubang.repository.StoneRepository;
import jakarta.transaction.Transactional;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class AnniversaryScheduler {

    private static final Logger logger = LoggerFactory.getLogger(AnniversaryScheduler.class);
    private final StoneRepository stoneRepository;
    private final ApplicationEventPublisher eventPublisher;

    @Scheduled(cron = "0 0 0 * * *", zone = "Asia/Seoul")
    @Transactional
    public void checkAnniversaryDaily() {
        logger.info("기념일 체크 스케줄러 시작");

        try {
            List<Stone> stones = stoneRepository.findAllByAdoptionDateIsNotNullAndDeletedAtIsNull();
            logger.info("처리할 돌 수: {}", stones.size());

            stones.forEach(stone -> {
                LocalDate adoptionDate = stone.getAdoptionDate();
                LocalDate today = LocalDate.now();
                long daysSinceAdoption = ChronoUnit.DAYS.between(adoptionDate, today) + 1;

                eventPublisher.publishEvent(
                    new AnniversaryEvent(
                        stone.getStoneId(),
                        stone.getMember().getMemberId(),
                        today,
                        daysSinceAdoption
                    )
                );
            });

            logger.info("기념일 체크 스케줄러 완료");
        } catch (Exception e) {
            logger.error("기념일 체크 중 오류 발생", e);
            throw e;
        }
    }
}
