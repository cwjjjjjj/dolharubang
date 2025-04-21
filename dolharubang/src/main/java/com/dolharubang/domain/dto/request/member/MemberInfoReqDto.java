package com.dolharubang.domain.dto.request.member;

import com.dolharubang.domain.entity.Member;
import lombok.Getter;

@Getter
public class MemberInfoReqDto {
    
    private String nickname;
    private String birthday;

    public static Member toEntity(MemberInfoReqDto dto) {
        return Member.builder()
            .nickname(dto.getNickname())
            .spaceName(dto.getBirthday())
            .build();
    }
}
