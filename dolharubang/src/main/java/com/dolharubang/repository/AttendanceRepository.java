package com.dolharubang.repository;

import com.dolharubang.domain.entity.Attendance;
import com.dolharubang.domain.entity.Member;
import java.time.LocalDate;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AttendanceRepository extends JpaRepository<Attendance, Long> {

    boolean existsByMemberAndDate(Member member, LocalDate date);

    long countByMember(Member member);

}
