package com.dolharubang.domain.dto.response;

import com.dolharubang.domain.entity.MemberMission;
import com.dolharubang.type.MissionStatusType;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class MemberMissionResDto {

    private Long id;
    private Long missionId;
    private MissionStatusType status;
    private Double progress;

    public static MemberMissionResDto fromEntity(MemberMission memberMission) {
        return MemberMissionResDto.builder()
            .id(memberMission.getId())
            .missionId(memberMission.getMission().getId())
            .status(memberMission.getStatus())
            .progress(memberMission.getProgress())
            .build();
    }
}
