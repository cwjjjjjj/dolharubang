package com.dolharubang.service;

import com.dolharubang.domain.entity.Attendance;
import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.event.AttendanceEvent;
import com.dolharubang.repository.AttendanceRepository;
import java.time.LocalDate;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AttendanceService {

    private static final Logger logger = LoggerFactory.getLogger(AttendanceService.class);

    private final AttendanceRepository attendanceRepository;
    private final ApplicationEventPublisher eventPublisher;

    @Transactional
    public void checkIn(Member member) {
        LocalDate today = LocalDate.now();

        if (!attendanceRepository.existsByMemberAndDate(member, today)) {
            // 출석 기록 저장
            Attendance attendance = attendanceRepository.save(
                Attendance.builder()
                    .member(member)
                    .date(today)
                    .build()
            );

            logger.info("출석 체크 완료 - memberId: {}, date: {}", member.getMemberId(), today);

            // 출석 이벤트 발행 (이벤트 기반 미션 연동)
            eventPublisher.publishEvent(new AttendanceEvent(member.getMemberId(), today));
        } else {
            logger.info("이미 출석한 회원 - memberId: {}, date: {}", member.getMemberId(), today);
        }
    }
}
