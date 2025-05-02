package com.dolharubang.domain.dto.request;

import com.dolharubang.domain.entity.Contest;
import com.dolharubang.domain.entity.Member;
import lombok.Getter;

@Getter
public class ContestReqDto {

    private Boolean isPublic;
    private String stoneName;

    public static Contest toEntity(ContestReqDto dto, Member member) {
        return Contest.builder()
            .member(member)
            .isPublic(dto.getIsPublic())
            .stoneName(dto.getStoneName())
            .build();
    }

}