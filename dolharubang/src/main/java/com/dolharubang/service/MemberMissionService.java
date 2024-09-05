package com.dolharubang.service;

import com.dolharubang.domain.dto.request.MemberMissionReqDto;
import com.dolharubang.domain.dto.response.MemberMissionResDto;
import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.MemberMission;
import com.dolharubang.domain.entity.Mission;
import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import com.dolharubang.repository.MemberMissionRepository;
import com.dolharubang.repository.MemberRepository;
import com.dolharubang.repository.MissionRepository;
import com.dolharubang.type.MissionStatusType;
import java.util.List;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class MemberMissionService {

    private final MemberMissionRepository memberMissionRepository;
    private final MemberRepository memberRepository;
    private final MissionRepository missionRepository;

    public MemberMissionService(MemberMissionRepository memberMissionRepository,
        MemberRepository memberRepository, MissionRepository missionRepository) {
        this.memberMissionRepository = memberMissionRepository;
        this.memberRepository = memberRepository;
        this.missionRepository = missionRepository;
    }

    @Transactional
    public MemberMissionResDto createMemberMission(MemberMissionReqDto requestDto) {
        // 1. 멤버 검증
        Member member = memberRepository.findById(requestDto.getMemberId())
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        // 2. 미션 검증
        Mission mission = missionRepository.findById(requestDto.getMissionId())
            .orElseThrow(() -> new CustomException(ErrorCode.MISSION_NOT_FOUND));

        // 3. 이미 해당 멤버가 이 미션을 가지고 있는지 검증
        boolean exists = memberMissionRepository.existsByMemberAndMission(member, mission);
        if (exists) {
            throw new CustomException(ErrorCode.DUPLICATE_MEMBER_MISSION);
        }

        MemberMission memberMission = MemberMissionReqDto.toEntity(requestDto, member, mission);
        MemberMission savedMemberMission = memberMissionRepository.save(memberMission);
        return MemberMissionResDto.fromEntity(savedMemberMission);
    }

    @Transactional
    public MemberMissionResDto updateMemberMission(Long id, MemberMissionReqDto requestDto) {
        // 1. 멤버 미션 검증 및 해당 멤버인지 검증
        MemberMission memberMission = memberMissionRepository.findById(id)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_MISSION_NOT_FOUND));

        if (!memberMission.getMember().getMemberId().equals(requestDto.getMemberId())) {
            throw new CustomException(ErrorCode.MEMBER_NOT_FOUND);
        }

        // 2. 상태와 진행도가 100%가 되면 상태 변경 로직
        MissionStatusType status = requestDto.getStatus();
        double progress = requestDto.getProgress();

        if ((status == MissionStatusType.PROGRESSING || status == MissionStatusType.NOT_STARTED)
            && Double.compare(progress, 100.0) == 0) {
            status = MissionStatusType.COMPLETED;
        }

        memberMission.updateStatus(status, progress);

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

    @Transactional(readOnly = true)
    public List<MemberMissionResDto> getAllMemberMissions() {
        return memberMissionRepository.findAll().stream()
            .map(MemberMissionResDto::fromEntity)
            .collect(Collectors.toList());
    }

    @Transactional
    public void deleteMemberMission(Long id) {
        MemberMission memberMission = memberMissionRepository.findById(id)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_MISSION_NOT_FOUND));
        memberMissionRepository.delete(memberMission);
    }

}
