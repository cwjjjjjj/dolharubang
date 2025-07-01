package com.dolharubang.repository;

import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.Mission;
import com.dolharubang.domain.entity.Stone;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface MissionRepository extends JpaRepository<Mission, Long> {

    @Query("SELECT m FROM Mission m LEFT JOIN MemberMission mm ON m.id = mm.mission.id AND mm.member = :member WHERE mm.mission.id IS NULL")
    List<Mission> findMissionsNotAssignedToMember(@Param("member") Member member);

    List<Mission> findByIsDaily(boolean isDaily);

    @Query(
        "SELECT m FROM Mission m WHERE m.condition.category = 'ANNIVERSARY' AND m.deletedAt IS NULL "
            + "AND m.id NOT IN (SELECT mm.mission.id FROM MemberMission mm "
            + "WHERE mm.member = :member AND mm.stone = :stone)")
    List<Mission> findUnassignedAnniversaryMissions(@Param("member") Member member,
        @Param("stone") Stone stone);


}
