package com.dolharubang.domain.dto.request;

import com.dolharubang.domain.entity.Member;
import lombok.Getter;

@Getter
public class MemberReqDto {

    private String memberEmail;
    private String nickname;
    private String birthday;
    private int sands;
    private String imageBase64;
    private String spaceName;

    public static Member toEntity(MemberReqDto dto) {
        return Member.builder()
            .memberEmail(dto.getMemberEmail())
            .nickname(dto.getNickname())
            .birthday(dto.getBirthday())
            .sands(dto.getSands())
            .spaceName(dto.getSpaceName())
            .build();
    }
}
