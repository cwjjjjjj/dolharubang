package com.dolharubang.domain.dto.response.member;

import com.dolharubang.domain.entity.Member;
import com.fasterxml.jackson.annotation.JsonGetter;
import lombok.Builder;
import lombok.Getter;
import lombok.ToString;

@Builder
@Getter
@ToString
public class MemberSearchResDto {

    private Long memberId;
    private String nickname;
    private String profileImageURL;
    private String spaceName;
    private boolean isFriend;
    private boolean isRequested; // 내가 요청 보냈는지
    private boolean isReceived;  // 내가 요청을 받았는지

    @JsonGetter("isFriend")
    public boolean getIsFriend() {
        return isFriend;
    }

    @JsonGetter("isRequested")
    public boolean getIsRequested() {
        return isRequested;
    }

    @JsonGetter("isReceived")
    public boolean getIsReceived() {
        return isReceived;
    }

    public static MemberSearchResDto fromEntity(
        Member member,
        boolean isFriend,
        boolean isRequested,
        boolean isReceived
    ) {
        return MemberSearchResDto.builder()
            .memberId(member.getMemberId())
            .nickname(member.getNickname())
            .profileImageURL(member.getProfilePicture())
            .spaceName(member.getSpaceName())
            .isFriend(isFriend)
            .isRequested(isRequested)
            .isReceived(isReceived)
            .build();
    }
}
