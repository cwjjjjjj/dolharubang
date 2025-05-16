package com.dolharubang.domain.dto.response;

import com.dolharubang.domain.entity.Contest;
import java.time.LocalDateTime;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Builder
@Getter
@Setter
@ToString
public class ContestResDto {

    private Long contestNo;
    private String nickname;
    private Boolean isPublic;
    private String profileImgUrl;
    private String stoneName;
    private LocalDateTime createdAt;
    private LocalDateTime modifiedAt;

    public static ContestResDto fromEntity(Contest contest) {
        return ContestResDto.builder()
            .contestNo(contest.getId())
            .nickname(contest.getMember().getNickname())
            .isPublic(contest.getIsPublic())
            .profileImgUrl(contest.getProfileImgUrl())
            .stoneName(contest.getStoneName())
            .createdAt(contest.getCreatedAt())
            .modifiedAt(contest.getModifiedAt())
            .build();
    }
}
