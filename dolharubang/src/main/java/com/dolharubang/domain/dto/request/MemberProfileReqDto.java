package com.dolharubang.domain.dto.request;

import com.dolharubang.domain.entity.Member;
import lombok.Getter;

@Getter
public class MemberProfileReqDto {
    
    private String nickname;
    private String spaceName;

    public static Member toEntity(MemberProfileReqDto dto) {
        return Member.builder()
            .nickname(dto.getNickname())
            .spaceName(dto.getSpaceName())
            .build();
    }
}
