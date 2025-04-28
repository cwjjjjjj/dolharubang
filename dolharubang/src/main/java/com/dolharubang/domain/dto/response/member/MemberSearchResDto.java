package com.dolharubang.domain.dto.response.member;

import com.dolharubang.domain.entity.Member;
import lombok.Builder;
import lombok.Getter;
import lombok.ToString;

@Builder
@Getter
@ToString
public class MemberSearchResDto {

    private Long memberId;
    private String nickname;
    private String profilePicture;
    private String spaceName;

    public static MemberSearchResDto fromEntity(Member member) {
        return MemberSearchResDto.builder()
            .memberId(member.getMemberId())
            .nickname(member.getNickname())
            .profilePicture(member.getProfilePicture())
            .spaceName(member.getSpaceName())
            .build();
    }
}
