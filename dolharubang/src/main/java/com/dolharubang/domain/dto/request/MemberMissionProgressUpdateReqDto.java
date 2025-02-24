package com.dolharubang.domain.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class MemberMissionProgressUpdateReqDto {

    @NotNull(message = "현재 달성값은 필수입니다")
    private Integer currentValue;

    private String eventType;  // 특정 이벤트 미션의 경우에만 필요
}