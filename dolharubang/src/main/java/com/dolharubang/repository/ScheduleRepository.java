package com.dolharubang.repository;

import com.dolharubang.domain.entity.Schedule;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface ScheduleRepository extends JpaRepository<Schedule, Long> {

    List<Schedule> findAllByMemberEmail(String memberEmail);

    @Query("SELECT s FROM Schedule s WHERE YEAR(s.scheduleDate) = :year AND MONTH(s.scheduleDate) = :month AND DAY(s.scheduleDate) = :day AND s.memberEmail = :email")
    List<Schedule> findByYearMonthDayAndEmail(@Param("year") int year, @Param("month") int month,
        @Param("day") int day, @Param("email") String email);

    @Query("SELECT s FROM Schedule s WHERE YEAR(s.scheduleDate) = :year AND MONTH(s.scheduleDate) = :month AND s.memberEmail = :email")
    List<Schedule> findByYearMonthAndEmail(@Param("year") int year, @Param("month") int month,
        @Param("email") String email);

    @Query("SELECT s FROM Schedule s WHERE YEAR(s.scheduleDate) = :year AND s.memberEmail = :email")
    List<Schedule> findByYearAndEmail(@Param("year") int year, @Param("email") String email);

    @Query("SELECT s FROM Schedule s WHERE s.memberEmail = :email")
    List<Schedule> findAllByEmail(@Param("email") String email);
}
