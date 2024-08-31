package com.dolharubang.service;

import com.dolharubang.domain.dto.request.ScheduleReqDto;
import com.dolharubang.domain.dto.response.ScheduleResDto;
import com.dolharubang.domain.entity.Schedule;
import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import com.dolharubang.repository.ScheduleRepository;
import java.util.List;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ScheduleService {

    private final ScheduleRepository scheduleRepository;

    public ScheduleService(ScheduleRepository scheduleRepository) {
        this.scheduleRepository = scheduleRepository;
    }

    @Transactional
    public ScheduleResDto createSchedule(ScheduleReqDto requestDto) {
        Schedule schedule = Schedule.builder()
            .memberEmail(requestDto.getMemberEmail())
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

        schedule.update(
            requestDto.getMemberEmail(),
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
        String email) {
        List<Schedule> schedules;

        if (year != null && month != null && day != null) {
            // 일별 조회
            schedules = scheduleRepository.findByYearMonthDayAndEmail(year, month, day, email);
        } else if (year != null && month != null) {
            // 월별 조회
            schedules = scheduleRepository.findByYearMonthAndEmail(year, month, email);
        } else if (year != null) {
            // 연도별 조회
            schedules = scheduleRepository.findByYearAndEmail(year, email);
        } else {
            // 전체 조회
            schedules = scheduleRepository.findAllByEmail(email);
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
