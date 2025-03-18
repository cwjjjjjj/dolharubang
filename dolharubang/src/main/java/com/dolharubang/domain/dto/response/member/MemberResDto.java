package com.dolharubang.domain.dto.response.member;

import com.dolharubang.domain.entity.Member;
import com.dolharubang.type.Authority;
import com.dolharubang.type.Provider;
import lombok.Builder;
import lombok.Getter;
import lombok.ToString;

@Builder
@Getter
@ToString
public class MemberResDto {

    private Long memberId;
    private Authority authority;
    private Provider provider;
    private String providerId;
    private String memberEmail;
    private String nickname;
    private String birthday;
    private int sands;
    private String profilePicture;
    private String spaceName;

    public static MemberResDto fromEntity(Member member) {
        return MemberResDto.builder()
            .memberId(member.getMemberId())
            .authority(member.getAuthority())
            .provider(member.getProvider())
            .providerId(member.getProviderId())
            .memberEmail(member.getMemberEmail())
            .nickname(member.getNickname())
            .birthday(member.getBirthday())
            .sands(member.getSands())
            .profilePicture(member.getProfilePicture())
            .spaceName(member.getSpaceName())
            .build();
    }
}
