package com.dolharubang.domain.dto.response.member;

import com.dolharubang.domain.entity.Member;
import com.fasterxml.jackson.annotation.JsonProperty;
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
    @JsonProperty("isFriend")
    private boolean isFriend;

    public static MemberSearchResDto fromEntity(Member member, boolean isFriend) {
        return MemberSearchResDto.builder()
            .memberId(member.getMemberId())
            .nickname(member.getNickname())
            .profilePicture(member.getProfilePicture())
            .spaceName(member.getSpaceName())
            .isFriend(isFriend)
            .build();
    }
}
