package com.dolharubang.service;

import com.dolharubang.domain.dto.request.MissionReqDto;
import com.dolharubang.domain.dto.response.MissionResDto;
import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.Mission;
import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import com.dolharubang.repository.MemberRepository;
import com.dolharubang.repository.MissionRepository;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class MissionService {

    private final MissionRepository missionRepository;
    private final MemberRepository memberRepository;

    public MissionService(MissionRepository missionRepository, MemberRepository memberRepository) {
        this.missionRepository = missionRepository;
        this.memberRepository = memberRepository;
    }

    @Transactional(readOnly = true)
    public List<Mission> getUnassignedMissionsForMember(Long memberId) {
        // 멤버의 유효성 체크
        Member member = memberRepository.findById(memberId)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        // 미션 조회
        return missionRepository.findMissionsNotAssignedToMember(member);
    }

    @Transactional
    public MissionResDto createMission(MissionReqDto requestDto) {
        // Mission 엔티티 생성 및 저장
        Mission mission = Mission.builder()
            .name(requestDto.getName())
            .description(requestDto.getDescription())
            .missionImgUrl(requestDto.getMissionImgUrl())
            .missionType(requestDto.getMissionType())
            .isHidden(requestDto.isHidden())
            .isDaily(requestDto.isDaily())
            .conditionDetail(requestDto.getConditionDetail())
            .rewardType(requestDto.getRewardType())
            .rewardQuantity(requestDto.getRewardQuantity())
            .rewardItemNo(requestDto.getRewardItemNo())
            .build();

        Mission savedMission = missionRepository.save(mission);
        return MissionResDto.fromEntity(savedMission);
    }

    @Transactional
    public MissionResDto updateMission(Long id, MissionReqDto requestDto) {
        // 존재하는 미션 조회 및 업데이트
        Mission mission = missionRepository.findById(id)
            .orElseThrow(() -> new CustomException(ErrorCode.MISSION_NOT_FOUND));

        mission.updateMission(
            requestDto.getName(),
            requestDto.getDescription(),
            requestDto.getMissionImgUrl(),
            requestDto.getMissionType(),
            requestDto.isHidden(),
            requestDto.isDaily(),
            requestDto.getConditionDetail(),
            requestDto.getRewardType(),
            requestDto.getRewardQuantity(),
            requestDto.getRewardItemNo()
        );

        Mission updatedMission = missionRepository.save(mission);
        return MissionResDto.fromEntity(updatedMission);
    }

    @Transactional(readOnly = true)
    public MissionResDto getMission(Long id) {
        // 미션 조회
        Mission mission = missionRepository.findById(id)
            .orElseThrow(() -> new CustomException(ErrorCode.MISSION_NOT_FOUND));

        return MissionResDto.fromEntity(mission);
    }
}
