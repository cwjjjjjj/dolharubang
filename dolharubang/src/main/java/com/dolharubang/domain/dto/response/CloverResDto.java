package com.dolharubang.domain.dto.response;

import com.dolharubang.domain.entity.Clover;
import lombok.Builder;
import lombok.Getter;
import lombok.ToString;

@Builder
@Getter
@ToString
public class CloverResDto {

    private Long cloverId;
    private Long sendingMemberId;
    private Long receivingMemberId;

    public static CloverResDto fromEntity(Clover clover) {
        return CloverResDto.builder()
                .cloverId(clover.getCloverId())
                .sendingMemberId(clover.getSendingMember().getMemberId())
                .receivingMemberId(clover.getReceivingMember().getMemberId())
                .build();
    }
}
