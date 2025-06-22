package com.dolharubang.domain.dto.request;

import com.dolharubang.domain.entity.Clover;
import com.dolharubang.domain.entity.Member;
import lombok.Getter;

@Getter
public class CloverReqDto {

    private Member receivingMember;

    public static Clover toEntity(CloverReqDto dto) {
        return Clover.builder()
                .receivingMember(dto.receivingMember)
                .build();
    }
}
