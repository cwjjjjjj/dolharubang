package com.dolharubang.service;

import com.dolharubang.domain.dto.request.MemberMissionProgressUpdateReqDto;
import com.dolharubang.domain.dto.response.MemberMissionResDto;
import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.MemberMission;
import com.dolharubang.domain.entity.Mission;
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
public class MemberMissionService {

    private final MemberMissionRepository memberMissionRepository;
    private final MemberRepository memberRepository;
    private final MissionRepository missionRepository;
    private final RewardService rewardService;

    public MemberMissionService(MemberMissionRepository memberMissionRepository,
        MemberRepository memberRepository, MissionRepository missionRepository,
        RewardService rewardService) {
        this.memberMissionRepository = memberMissionRepository;
        this.memberRepository = memberRepository;
        this.missionRepository = missionRepository;
        this.rewardService = rewardService;
    }

    @Transactional
    public MemberMissionResDto updateMissionProgress(Long id,
        MemberMissionProgressUpdateReqDto requestDto) {
        MemberMission memberMission = memberMissionRepository.findById(id)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_MISSION_NOT_FOUND));

        memberMission.updateProgress(requestDto.getCurrentValue(), requestDto.getEventType());
        return MemberMissionResDto.fromEntity(memberMission);
    }

    @Transactional
    public MemberMissionResDto claimReward(Long memberMissionId) {
        MemberMission memberMission = memberMissionRepository.findById(memberMissionId)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_MISSION_NOT_FOUND));

        // 보상 지급 가능 여부 확인
        if (!memberMission.canReceiveReward()) {
            throw new CustomException(ErrorCode.INVALID_REWARD_CLAIM);
        }

        // 보상 지급
        Mission mission = memberMission.getMission();
        rewardService.giveReward(
            memberMission.getMember(),
            mission.getReward().getType(),
            mission.getReward().getQuantity(),
            mission.getReward().getItemNo()
        );

        // 보상 지급 완료 표시
        memberMission.markAsRewarded();

        return MemberMissionResDto.fromEntity(memberMission);
    }

    @Transactional(readOnly = true)
    public List<MemberMissionResDto> getMemberMissions(Long memberId) {
        Member member = memberRepository.findById(memberId)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        List<MemberMission> memberMissions = memberMissionRepository.findByMember(member);

        return memberMissions.stream()
            .map(MemberMissionResDto::fromEntity)
            .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public MemberMissionResDto getMemberMission(Long id) {
        MemberMission memberMission = memberMissionRepository.findById(id)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_MISSION_NOT_FOUND));
        return MemberMissionResDto.fromEntity(memberMission);
    }

    @Transactional
    public void assignDailyMissionsToMember(Member member) {
        // isDaily가 true인 미션 목록 조회
        List<Mission> dailyMissions = missionRepository.findByIsDaily(true);

        // 회원에게 데일리 미션 할당
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
