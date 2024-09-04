package com.dolharubang.domain.dto.request;

import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.MemberMission;
import com.dolharubang.domain.entity.Mission;
import com.dolharubang.type.MissionStatusType;
import lombok.Getter;

@Getter
public class MemberMissionReqDto {

    private Long memberId;
    private Long missionId;
    private MissionStatusType status;
    private Double progress;

    public static MemberMission toEntity(MemberMissionReqDto dto, Member member, Mission mission) {
        return MemberMission.builder()
            .member(member)
            .mission(mission)
            .status(dto.getStatus())
            .progress(dto.getProgress())
            .build();
    }
}
