package com.dolharubang.domain.dto.response.member;

import com.dolharubang.domain.entity.Member;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Builder;
import lombok.Getter;
import lombok.ToString;

@Builder
@Getter
@ToString
public class MemberProfileResDto {

    @JsonProperty("emailAddress")
    private String memberEmail;
    @JsonProperty("userName")
    private String nickname;
    @JsonProperty("birthDay")
    private String birthday;
    @JsonProperty("birthStone")
    private String birthStone;
    @JsonProperty("roomName")
    private String spaceName;

    public static MemberProfileResDto fromEntity(Member member) {
        return MemberProfileResDto.builder()
            .memberEmail(member.getMemberEmail())
            .nickname(member.getNickname())
            .birthday(member.getBirthday())
            .birthStone("가넷")
            .spaceName(member.getSpaceName())
            .build();
    }
}
