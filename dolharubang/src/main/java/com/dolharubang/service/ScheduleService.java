package com.dolharubang.service;

import com.dolharubang.domain.dto.request.ScheduleReqDto;
import com.dolharubang.domain.dto.response.ScheduleResDto;
import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.Schedule;
import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import com.dolharubang.repository.MemberRepository;
import com.dolharubang.repository.ScheduleRepository;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ScheduleService {

    private final ScheduleRepository scheduleRepository;
    private final MemberRepository memberRepository;

    public ScheduleService(ScheduleRepository scheduleRepository,
        MemberRepository memberRepository) {
        this.scheduleRepository = scheduleRepository;
        this.memberRepository = memberRepository;
    }

    @Transactional
    public ScheduleResDto createSchedule(ScheduleReqDto requestDto) {
        Member member = memberRepository.findById(requestDto.getMemberId())
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        Schedule schedule = Schedule.builder()
            .member(member)
            .contents(requestDto.getContents())
            .startScheduleDate(requestDto.getStartScheduleDate())
            .endScheduleDate(requestDto.getEndScheduleDate())
            .isAlarm(requestDto.getIsAlarm())
            .alarmTime(requestDto.getAlarmTime())
            .build();

        Schedule savedSchedule = scheduleRepository.save(schedule);
        return ScheduleResDto.fromEntity(savedSchedule);
    }

    @Transactional
    public ScheduleResDto updateSchedule(Long id, ScheduleReqDto requestDto) {
        Schedule schedule = scheduleRepository.findById(id)
            .orElseThrow(() -> new CustomException(ErrorCode.SCHEDULE_NOT_FOUND));

        Member member = memberRepository.findById(requestDto.getMemberId())
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        schedule.update(
            member,
            requestDto.getContents(),
            requestDto.getStartScheduleDate(),
            requestDto.getEndScheduleDate(),
            requestDto.getIsAlarm(),
            requestDto.getAlarmTime()
        );

        return ScheduleResDto.fromEntity(schedule);
    }

    @Transactional(readOnly = true)
    public ScheduleResDto getSchedule(Long id) {
        Schedule schedule = scheduleRepository.findById(id)
            .orElseThrow(() -> new CustomException(ErrorCode.SCHEDULE_NOT_FOUND));

        return ScheduleResDto.fromEntity(schedule);
    }

    @Transactional(readOnly = true)
    public List<ScheduleResDto> getSchedulesByCriteria(Integer year, Integer month, Integer day,
        Long memberId) {
        Member member = memberRepository.findById(memberId)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        List<Schedule> schedules;

        if (year != null && month != null && day != null) {
            LocalDateTime startOfDay = LocalDate.of(year, month, day).atStartOfDay();
            LocalDateTime endOfDay = LocalDate.of(year, month, day).atTime(LocalTime.MAX);
            schedules = scheduleRepository.findByDayRangeAndMember(startOfDay, endOfDay, member);
        } else if (year != null && month != null) {
            LocalDateTime startOfMonth = LocalDate.of(year, month, 1).atStartOfDay();
            LocalDateTime endOfMonth = LocalDate.of(year, month, 1).plusMonths(1).minusDays(1)
                .atTime(LocalTime.MAX);
            schedules = scheduleRepository.findByMonthAndMember(startOfMonth, endOfMonth, member);
        } else if (year != null) {
            LocalDateTime startOfYear = LocalDate.of(year, 1, 1).atStartOfDay();
            LocalDateTime endOfYear = LocalDate.of(year, 12, 31).atTime(LocalTime.MAX);
            schedules = scheduleRepository.findByYearAndMember(startOfYear, endOfYear, member);
        } else {
            schedules = scheduleRepository.findAllByMember(member);
        }

        if (schedules.isEmpty()) {
            throw new CustomException(ErrorCode.SCHEDULE_NOT_FOUND, "해당 조건에 맞는 스케줄이 없습니다.");
        }

        return schedules.stream()
            .map(ScheduleResDto::fromEntity)
            .collect(Collectors.toList());
    }

    @Transactional
    public void deleteSchedule(Long id) {
        Schedule schedule = scheduleRepository.findById(id)
            .orElseThrow(() -> new CustomException(ErrorCode.SCHEDULE_NOT_FOUND));

        scheduleRepository.delete(schedule);
    }
}
