package com.dolharubang.repository;

import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.MemberMission;
import com.dolharubang.domain.entity.Mission;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface MemberMissionRepository extends JpaRepository<MemberMission, Long> {

    boolean existsByMemberAndMission(Member member, Mission mission);

    @Query("SELECT mm FROM MemberMission mm WHERE mm.mission.isDaily = true")
    List<MemberMission> findDailyMissions();

    List<MemberMission> findByMember(Member member);
}
