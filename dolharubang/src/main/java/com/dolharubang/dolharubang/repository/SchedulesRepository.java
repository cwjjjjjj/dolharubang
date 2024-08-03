package com.dolharubang.dolharubang.repository;

import com.dolharubang.dolharubang.domain.entity.Schedules;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface SchedulesRepository extends JpaRepository<Schedules, Long> {

    List<Schedules> findAllByMemberEmail(String memberEmail);

    @Query("SELECT s FROM Schedules s WHERE YEAR(s.scheduleDate) = :year AND MONTH(s.scheduleDate) = :month AND DAY(s.scheduleDate) = :day AND s.memberEmail = :email")
    List<Schedules> findByYearMonthDayAndEmail(@Param("year") int year, @Param("month") int month,
        @Param("day") int day, @Param("email") String email);

    @Query("SELECT s FROM Schedules s WHERE YEAR(s.scheduleDate) = :year AND MONTH(s.scheduleDate) = :month AND s.memberEmail = :email")
    List<Schedules> findByYearMonthAndEmail(@Param("year") int year, @Param("month") int month,
        @Param("email") String email);

    @Query("SELECT s FROM Schedules s WHERE YEAR(s.scheduleDate) = :year AND s.memberEmail = :email")
    List<Schedules> findByYearAndEmail(@Param("year") int year, @Param("email") String email);

    @Query("SELECT s FROM Schedules s WHERE s.memberEmail = :email")
    List<Schedules> findAllByEmail(@Param("email") String email);
}
