package com.dolharubang.service;

import com.dolharubang.domain.dto.request.MemberMissionProgressUpdateReqDto;
import com.dolharubang.domain.dto.response.MemberMissionResDto;
import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.MemberMission;
import com.dolharubang.domain.entity.Mission;
import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import com.dolharubang.mongo.service.ItemService;
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
    private final ItemService itemService;

    public MemberMissionService(MemberMissionRepository memberMissionRepository,
        MemberRepository memberRepository,
        MissionRepository missionRepository,
        RewardService rewardService,
        ItemService itemService) {
        this.memberMissionRepository = memberMissionRepository;
        this.memberRepository = memberRepository;
        this.missionRepository = missionRepository;
        this.rewardService = rewardService;
        this.itemService = itemService;
    }

    @Transactional
    public MemberMissionResDto updateMissionProgress(Long id, Long memberId,
        MemberMissionProgressUpdateReqDto requestDto) {
        MemberMission memberMission = getOwnedMission(id, memberId);
        memberMission.updateProgress(requestDto.getCurrentValue(), requestDto.getEventType());
        return MemberMissionResDto.fromEntity(memberMission, itemService);
    }

    @Transactional
    public MemberMissionResDto claimReward(Long memberMissionId, Long memberId) {
        MemberMission memberMission = getOwnedMission(memberMissionId, memberId);

        if (!memberMission.canReceiveReward()) {
            throw new CustomException(ErrorCode.INVALID_REWARD_CLAIM);
        }

        Mission mission = memberMission.getMission();
        rewardService.giveReward(
            memberMission.getMember(),
            mission.getReward().getType(),
            mission.getReward().getQuantity(),
            mission.getReward().getItemNo()
        );

        memberMission.markAsRewarded();
        return MemberMissionResDto.fromEntity(memberMission, itemService);
    }

    @Transactional(readOnly = true)
    public List<MemberMissionResDto> getMemberMissions(Long memberId) {
        Member member = memberRepository.findById(memberId)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        return memberMissionRepository.findByMember(member).stream()
            .map(mission -> MemberMissionResDto.fromEntity(mission, itemService))
            .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public MemberMissionResDto getMemberMission(Long id, Long memberId) {
        MemberMission memberMission = getOwnedMission(id, memberId);
        return MemberMissionResDto.fromEntity(memberMission, itemService);
    }

    @Transactional
    public void assignDailyMissionsToMember(Member member) {
        List<Mission> dailyMissions = missionRepository.findByIsDaily(true);
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

    // 권한 확인 메서드
    private MemberMission getOwnedMission(Long missionId, Long memberId) {
        MemberMission mission = memberMissionRepository.findById(missionId)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_MISSION_NOT_FOUND));

        if (!mission.getMember().getMemberId().equals(memberId)) {
            throw new CustomException(ErrorCode.FORBIDDEN);
        }

        return mission;
    }
}

