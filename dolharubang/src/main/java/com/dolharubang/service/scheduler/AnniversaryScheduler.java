package com.dolharubang.service.scheduler;

import com.dolharubang.domain.entity.Stone;
import com.dolharubang.domain.event.AnniversaryEvent;
import com.dolharubang.repository.StoneRepository;
import jakarta.transaction.Transactional;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class AnniversaryScheduler {

    private final StoneRepository stoneRepository;
    private final ApplicationEventPublisher eventPublisher;

    // 매일 00:00:00에 실행 (cron = "초 분 시 일 월 요일")
    @Scheduled(cron = "0 0 0 * * *", zone = "Asia/Seoul")
    @Transactional
    public void checkAnniversaryDaily() {
        List<Stone> stones = stoneRepository.findAllByAdoptionDateIsNotNullAndIsDeletedIsNull();

        stones.forEach(stone -> {
            LocalDate adoptionDate = stone.getAdoptionDate();
            LocalDate today = LocalDate.now();
            long daysSinceAdoption = ChronoUnit.DAYS.between(adoptionDate, today);

            eventPublisher.publishEvent(
                new AnniversaryEvent(
                    stone.getStoneId(),
                    stone.getMember().getMemberId(),
                    today,
                    daysSinceAdoption
                )
            );
        });
    }

}
