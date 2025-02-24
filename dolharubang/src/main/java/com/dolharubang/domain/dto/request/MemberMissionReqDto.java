package com.dolharubang.domain.dto.request;

import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.MemberMission;
import com.dolharubang.domain.entity.Mission;
import com.dolharubang.type.MissionStatusType;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;

@Getter
public class MemberMissionReqDto {

    @NotNull(message = "회원 ID는 필수입니다")
    private Long memberId;

    @NotNull(message = "미션 ID는 필수입니다")
    private Long missionId;

    private MissionStatusType status;  // 추가
    private Double progress;           // 추가

    public static MemberMission toEntity(MemberMissionReqDto dto, Member member, Mission mission) {
        return MemberMission.builder()
            .member(member)
            .mission(mission)
            .build();
    }
}
