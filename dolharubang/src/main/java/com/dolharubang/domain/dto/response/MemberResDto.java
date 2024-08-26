package com.dolharubang.domain.dto.response;

import com.dolharubang.domain.entity.Member;
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
    private String refreshToken;
    private String provider;
    private Long sands;
    private LocalDateTime createdAt;
    private LocalDateTime lastLoginAt;
    private LocalDateTime modifiedAt;
    private Long totalLoginDays;
    private String profilePicture;
    private String spaceName;

    public static MemberResDto fromEntity(Member member) {
        return MemberResDto.builder()
            .memberId(member.getMemberId())
            .memberEmail(member.getMemberEmail())
            .nickname(member.getNickname())
            .birthday(member.getBirthday())
            .refreshToken(member.getRefreshToken())
            .provider(member.getProvider())
            .sands(member.getSands())
            .createdAt(member.getCreatedAt())
            .lastLoginAt(member.getLastLoginAt())
            .modifiedAt(member.getModifiedAt())
            .totalLoginDays(member.getTotalLoginDays())
            .spaceName(member.getSpaceName())
            .build();
    }
}
