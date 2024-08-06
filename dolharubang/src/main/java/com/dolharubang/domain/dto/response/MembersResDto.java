package com.dolharubang.domain.dto.response;

import com.dolharubang.domain.entity.Members;
import java.time.LocalDateTime;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Builder
@Getter
@Setter
@ToString
public class MembersResDto {

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

    public static MembersResDto fromEntity(Members members) {
        return MembersResDto.builder()
            .memberEmail(members.getMemberEmail())
            .nickname(members.getNickname())
            .birthday(members.getBirthday())
            .refreshToken(members.getRefreshToken())
            .provider(members.getProvider())
            .sands(members.getSands())
            .createdAt(members.getCreatedAt())
            .lastLoginAt(members.getLastLoginAt())
            .modifiedAt(members.getModifiedAt())
            .totalLoginDays(members.getTotalLoginDays())
            .spaceName(members.getSpaceName())
            .build();
    }
}
