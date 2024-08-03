package com.dolharubang.dolharubang.service;

import com.dolharubang.dolharubang.domain.dto.request.SchedulesReqDto;
import com.dolharubang.dolharubang.domain.dto.response.SchedulesResDto;
import com.dolharubang.dolharubang.domain.entity.Schedules;
import com.dolharubang.dolharubang.exception.CustomException;
import com.dolharubang.dolharubang.exception.ErrorCode;
import com.dolharubang.dolharubang.repository.SchedulesRepository;
import java.util.List;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class SchedulesService {

    private final SchedulesRepository schedulesRepository;

    public SchedulesService(SchedulesRepository schedulesRepository) {
        this.schedulesRepository = schedulesRepository;
    }

    @Transactional
    public SchedulesResDto createSchedule(SchedulesReqDto requestDto) {
        Schedules schedule = Schedules.builder()
            .memberEmail(requestDto.getMemberEmail())
            .contents(requestDto.getContents())
            .scheduleDate(requestDto.getScheduleDate())
            .isAlarm(requestDto.getIsAlarm())
            .alarmTime(requestDto.getAlarmTime())
            .build();

        Schedules savedSchedule = schedulesRepository.save(schedule);
        return SchedulesResDto.fromEntity(savedSchedule);
    }

    @Transactional
    public SchedulesResDto updateSchedule(Long id, SchedulesReqDto requestDto) {
        Schedules schedule = schedulesRepository.findById(id)
            .orElseThrow(() -> new CustomException(ErrorCode.SCHEDULE_NOT_FOUND));

        schedule.update(
            requestDto.getMemberEmail(),
            requestDto.getContents(),
            requestDto.getScheduleDate(),
            requestDto.getIsAlarm(),
            requestDto.getAlarmTime()
        );

        return SchedulesResDto.fromEntity(schedule);
    }

    @Transactional(readOnly = true)
    public SchedulesResDto getSchedule(Long id) {
        Schedules schedule = schedulesRepository.findById(id)
            .orElseThrow(() -> new CustomException(ErrorCode.SCHEDULE_NOT_FOUND));

        return SchedulesResDto.fromEntity(schedule);
    }

    @Transactional(readOnly = true)
    public List<SchedulesResDto> getSchedulesByCriteria(Integer year, Integer month, Integer day,
        String email) {
        List<Schedules> schedules;

        if (year != null && month != null && day != null) {
            // 일별 조회
            schedules = schedulesRepository.findByYearMonthDayAndEmail(year, month, day, email);
        } else if (year != null && month != null) {
            // 월별 조회
            schedules = schedulesRepository.findByYearMonthAndEmail(year, month, email);
        } else if (year != null) {
            // 연도별 조회
            schedules = schedulesRepository.findByYearAndEmail(year, email);
        } else {
            // 전체 조회
            schedules = schedulesRepository.findAllByEmail(email);
        }

        if (schedules.isEmpty()) {
            throw new CustomException(ErrorCode.SCHEDULE_NOT_FOUND, "해당 조건에 맞는 스케줄이 없습니다.");
        }

        return schedules.stream()
            .map(SchedulesResDto::fromEntity)
            .collect(Collectors.toList());
    }

    @Transactional
    public void deleteSchedule(Long id) {
        Schedules schedule = schedulesRepository.findById(id)
            .orElseThrow(() -> new CustomException(ErrorCode.SCHEDULE_NOT_FOUND));

        schedulesRepository.delete(schedule);
    }
}
