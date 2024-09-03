package com.dolharubang.repository;

import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.Schedule;
import java.time.LocalDateTime;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface ScheduleRepository extends JpaRepository<Schedule, Long> {

    @Query("SELECT s FROM Schedule s WHERE s.startScheduleDate <= :endOfDay AND s.endScheduleDate >= :startOfDay AND s.member = :member")
    List<Schedule> findByDayRangeAndMember(
        @Param("startOfDay") LocalDateTime startOfDay,
        @Param("endOfDay") LocalDateTime endOfDay,
        @Param("member") Member member);

    @Query("SELECT s FROM Schedule s WHERE s.startScheduleDate >= :startOfMonth AND s.endScheduleDate <= :endOfMonth AND s.member = :member")
    List<Schedule> findByMonthAndMember(
        @Param("startOfMonth") LocalDateTime startOfMonth,
        @Param("endOfMonth") LocalDateTime endOfMonth,
        @Param("member") Member member);

    @Query("SELECT s FROM Schedule s WHERE s.startScheduleDate >= :startOfYear AND s.endScheduleDate <= :endOfYear AND s.member = :member")
    List<Schedule> findByYearAndMember(
        @Param("startOfYear") LocalDateTime startOfYear,
        @Param("endOfYear") LocalDateTime endOfYear,
        @Param("member") Member member);

    @Query("SELECT s FROM Schedule s WHERE s.member = :member")
    List<Schedule> findAllByMember(@Param("member") Member member);

}
