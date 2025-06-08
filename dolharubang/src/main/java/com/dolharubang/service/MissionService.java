package com.dolharubang.service;

import com.dolharubang.domain.dto.request.MissionReqDto;
import com.dolharubang.domain.dto.response.MissionResDto;
import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.MemberMission;
import com.dolharubang.domain.entity.Mission;
import com.dolharubang.domain.entity.MissionCondition;
import com.dolharubang.domain.entity.MissionReward;
import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import com.dolharubang.repository.MemberMissionRepository;
import com.dolharubang.repository.MemberRepository;
import com.dolharubang.repository.MissionRepository;
import java.util.List;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional(readOnly = true)
public class MissionService {

    private final MissionRepository missionRepository;
    private final MemberMissionRepository memberMissionRepository;
    private final MemberRepository memberRepository;

    public MissionService(MissionRepository missionRepository,
        MemberMissionRepository memberMissionRepository, MemberRepository memberRepository) {
        this.missionRepository = missionRepository;
        this.memberMissionRepository = memberMissionRepository;
        this.memberRepository = memberRepository;
    }

    public List<Mission> getUnassignedMissionsForMember(Member member) {
        return missionRepository.findMissionsNotAssignedToMember(member);
    }


    @Transactional
    public MissionResDto createMission(MissionReqDto requestDto) {
        Mission mission = requestDto.toEntity();
        Mission savedMission = missionRepository.save(mission);

        // 모든 회원에게 미션 할당
        List<Member> allMembers = memberRepository.findAll();
        List<MemberMission> memberMissions = allMembers.stream()
            .map(member -> MemberMission.builder()
                .member(member)
                .mission(savedMission)
                .build())
            .collect(Collectors.toList());
        memberMissionRepository.saveAll(memberMissions);

        return MissionResDto.fromEntity(savedMission);
    }

    @Transactional
    public MissionResDto updateMission(Long id, MissionReqDto requestDto) {
        Mission mission = missionRepository.findById(id)
            .orElseThrow(() -> new CustomException(ErrorCode.MISSION_NOT_FOUND));

        boolean wasDaily = mission.isDaily();

        mission.update(
            requestDto.getName(),
            requestDto.getDescription(),
            requestDto.isHidden(),
            requestDto.isDaily(),
            MissionCondition.builder()
                .category(requestDto.getCategory())
                .conditionType(requestDto.getConditionType())
                .requiredValue(requestDto.getRequiredValue())
                .periodDays(requestDto.getPeriodDays())
                .details(requestDto.getDetails())
                .build(),
            MissionReward.builder()
                .type(requestDto.getRewardType())
                .quantity(requestDto.getRewardQuantity())
                .itemNo(requestDto.getRewardItemNo())
                .build()
        );

        if (!wasDaily && mission.isDaily()) {
            updateDailyMissionsForAllMembers();
        }

        return MissionResDto.fromEntity(mission);
    }

    public MissionResDto getMission(Long id) {
        Mission mission = missionRepository.findById(id)
            .orElseThrow(() -> new CustomException(ErrorCode.MISSION_NOT_FOUND));
        return MissionResDto.fromEntity(mission);
    }

    @Transactional
    public void updateDailyMissionsForAllMembers() {
        List<Member> allMembers = memberRepository.findAll();
        List<Mission> dailyMissions = missionRepository.findByIsDaily(true);

        for (Member member : allMembers) {
            // 기존 데일리 미션 중 더 이상 데일리가 아닌 미션 삭제
            memberMissionRepository.deleteByMemberAndMissionNotIn(member, dailyMissions);

            // 새로운 데일리 미션 할당
            for (Mission mission : dailyMissions) {
                if (!memberMissionRepository.existsByMemberAndMission(member, mission)) {
                    MemberMission memberMission = MemberMission.builder()
                        .member(member)
                        .mission(mission)
                        .build();
                    memberMissionRepository.save(memberMission);
                }
            }
        }
    }

    @Transactional
    public void assignAllMissionsToNewMember(Member member) {
        List<Mission> allMissions = missionRepository.findAll();
        List<MemberMission> memberMissions = allMissions.stream()
            .map(mission -> MemberMission.builder()
                .member(member)
                .mission(mission)
                .build())
            .collect(Collectors.toList());
        memberMissionRepository.saveAll(memberMissions);
    }

}