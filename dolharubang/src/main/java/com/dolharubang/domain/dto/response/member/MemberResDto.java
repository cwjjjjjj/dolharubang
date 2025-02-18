package com.dolharubang.domain.dto.response.member;

import com.dolharubang.domain.entity.Member;
import java.time.LocalDateTime;
import lombok.Builder;
import lombok.Getter;
import lombok.ToString;

@Builder
@Getter
@ToString
public class MemberResDto {

    private Long memberId;
    private String memberEmail;
    private String nickname;
    private String birthday;
    private int sands;
    private LocalDateTime lastLoginAt;
    private int totalLoginDays;
    private String profilePicture;
    private String spaceName;

    public static MemberResDto fromEntity(Member member) {
        return MemberResDto.builder()
            .memberId(member.getMemberId())
            .memberEmail(member.getMemberEmail())
            .nickname(member.getNickname())
            .birthday(member.getBirthday())
            .sands(member.getSands())
            .lastLoginAt(member.getLastLoginAt())
            .totalLoginDays(member.getTotalLoginDays())
            .profilePicture(member.getProfilePicture())
            .spaceName(member.getSpaceName())
            .build();
    }
}
