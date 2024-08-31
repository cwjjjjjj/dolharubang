package com.dolharubang.service;

import com.dolharubang.domain.dto.request.ScheduleReqDto;
import com.dolharubang.domain.dto.response.ScheduleResDto;
import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.Schedule;
import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import com.dolharubang.repository.MemberRepository;
import com.dolharubang.repository.ScheduleRepository;
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
            .scheduleDate(requestDto.getScheduleDate())
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
            requestDto.getScheduleDate(),
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
            // 일별 조회
            schedules = scheduleRepository.findByYearMonthDayAndMember(year, month, day, member);
        } else if (year != null && month != null) {
            // 월별 조회
            schedules = scheduleRepository.findByYearMonthAndMember(year, month, member);
        } else if (year != null) {
            // 연도별 조회
            schedules = scheduleRepository.findByYearAndMember(year, member);
        } else {
            // 전체 조회
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
