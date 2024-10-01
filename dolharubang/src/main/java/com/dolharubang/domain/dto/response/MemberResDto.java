package com.dolharubang.domain.dto.response;

import com.dolharubang.domain.entity.Member;
import com.dolharubang.oauth2.model.Role;
import java.time.LocalDateTime;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Builder
@Getter
@Setter
@ToString
public class MemberResDto {

    private Long memberId;
    private String memberEmail;
    private String nickname;
    private String birthday;
    private Long sands;
    private Role role;
    private LocalDateTime lastLoginAt;
    private Long totalLoginDays;
    private String profilePicture;
    private String spaceName;

    public static MemberResDto fromEntity(Member member) {
        return MemberResDto.builder()
            .memberId(member.getMemberId())
            .memberEmail(member.getMemberEmail())
            .nickname(member.getNickname())
            .birthday(member.getBirthday())
            .sands(member.getSands())
            .role(member.getRole())
            .lastLoginAt(member.getLastLoginAt())
            .totalLoginDays(member.getTotalLoginDays())
            .spaceName(member.getSpaceName())
            .build();
    }
}
