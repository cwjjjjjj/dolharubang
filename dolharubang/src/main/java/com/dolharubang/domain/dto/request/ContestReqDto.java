package com.dolharubang.domain.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;

@Getter
public class ContestReqDto {

    @NotNull(message = "stoneId는 필수입니다.")
    private Long stoneId;
    private Boolean isPublic;

}