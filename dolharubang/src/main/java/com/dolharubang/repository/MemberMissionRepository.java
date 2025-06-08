package com.dolharubang.repository;

import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.MemberMission;
import com.dolharubang.domain.entity.Mission;
import com.dolharubang.type.MissionCategory;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface MemberMissionRepository extends JpaRepository<MemberMission, Long> {

    boolean existsByMemberAndMission(Member member, Mission mission);

    @Query("SELECT mm FROM MemberMission mm JOIN mm.mission m WHERE m.isDaily = true")
    List<MemberMission> findDailyMissions();

    List<MemberMission> findByMember(Member member);

    void deleteByMemberAndMissionNotIn(Member member, List<Mission> missions);

    void deleteAllByMember(Member member);

    List<MemberMission> findByMemberAndMission_Condition_Category(Member member,
        MissionCategory category);
}
