package com.dolharubang.repository;

import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.Schedule;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface ScheduleRepository extends JpaRepository<Schedule, Long> {

    @Query("SELECT s FROM Schedule s WHERE YEAR(s.scheduleDate) = :year AND MONTH(s.scheduleDate) = :month AND DAY(s.scheduleDate) = :day AND s.member = :member")
    List<Schedule> findByYearMonthDayAndMember(@Param("year") int year, @Param("month") int month,
        @Param("day") int day, @Param("member") Member member);

    @Query("SELECT s FROM Schedule s WHERE YEAR(s.scheduleDate) = :year AND MONTH(s.scheduleDate) = :month AND s.member = :member")
    List<Schedule> findByYearMonthAndMember(@Param("year") int year, @Param("month") int month,
        @Param("member") Member member);

    @Query("SELECT s FROM Schedule s WHERE YEAR(s.scheduleDate) = :year AND s.member = :member")
    List<Schedule> findByYearAndMember(@Param("year") int year, @Param("member") Member member);

    @Query("SELECT s FROM Schedule s WHERE s.member = :member")
    List<Schedule> findAllByMember(@Param("member") Member member);

}
