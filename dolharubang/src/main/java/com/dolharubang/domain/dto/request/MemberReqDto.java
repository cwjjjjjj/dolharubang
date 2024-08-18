package com.dolharubang.domain.dto.request;

import com.dolharubang.domain.entity.Member;
import lombok.Getter;

/*

엔티티는 데이터베이스 영속성(persistent)의 목적으로 사용되는 객체이고
요청, 응답을 전달하는 클래스로 함께 사용될 경우 변경될 가능성이 크며,
데이터베이스에 직접적인 영향을 줘서 DTO를 분리한다

 */

@Getter
public class MemberReqDto {
    private String MemberEmail;
    private String nickname;
    private String birthday;

    //private String refreshToken;
    //넣어야되나.......?

    private Long sands;
    private String profilePicture;
    private String spaceName;

    public static Member toEntity(MemberReqDto dto) {
        return Member.builder()
            .memberEmail(dto.getMemberEmail())
            .nickname(dto.getNickname())
            .birthday(dto.getBirthday())
            .sands(dto.getSands())
            .profilePicture(dto.getProfilePicture())
            .spaceName(dto.getSpaceName())
            .build();
    }
}
