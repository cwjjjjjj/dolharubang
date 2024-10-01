package com.dolharubang.domain.dto.request;

import com.dolharubang.domain.entity.Member;
import com.dolharubang.oauth2.model.Role;
import lombok.Getter;

@Getter
public class MemberReqDto {

    private String memberEmail;
    private String nickname;
    private String birthday;
    private Long sands;
    private Role role;
    private Long totalLoginDays;
    private String profilePicture;
    private String spaceName;

    public static Member toEntity(MemberReqDto dto) {
        return Member.builder()
            .memberEmail(dto.getMemberEmail())
            .nickname(dto.getNickname())
            .birthday(dto.getBirthday())
            .sands(dto.getSands())
            .role(dto.getRole())
            .profilePicture(dto.getProfilePicture())
            .totalLoginDays(dto.getTotalLoginDays())
            .spaceName(dto.getSpaceName())
            .build();
    }
}
