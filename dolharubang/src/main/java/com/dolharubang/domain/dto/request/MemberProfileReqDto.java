package com.dolharubang.domain.dto.request;

import com.dolharubang.domain.entity.Member;
import lombok.Getter;

@Getter
public class MemberProfileReqDto {
    
    private String nickname;
    private String profilePicture;
    private String spaceName;

    public static Member toEntity(MemberProfileReqDto dto) {
        return Member.builder()
            .nickname(dto.getNickname())
            .profilePicture(dto.getProfilePicture())
            .spaceName(dto.getSpaceName())
            .build();
    }
}
