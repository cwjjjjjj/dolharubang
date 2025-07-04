package com.dolharubang.domain.dto.response;

import com.dolharubang.domain.entity.Contest;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import java.time.LocalDateTime;

@Builder
@Getter
@Setter
@ToString
public class ContestWithCloverResDto {

    private Long contestNo;
    private String nickname;
    private Boolean isPublic;
    private String profileImgUrl;
    private String stoneName;
    private LocalDateTime createdAt;
    private LocalDateTime modifiedAt;
    private boolean isSentCloverToday;

    public static ContestWithCloverResDto fromEntity(Contest contest, boolean isSentCloverToday) {
        return ContestWithCloverResDto.builder()
            .contestNo(contest.getId())
            .nickname(contest.getMember().getNickname())
            .isPublic(contest.getIsPublic())
            .profileImgUrl(contest.getProfileImgUrl())
            .stoneName(contest.getStone().getStoneName())
            .createdAt(contest.getCreatedAt())
            .modifiedAt(contest.getModifiedAt())
            .isSentCloverToday(isSentCloverToday)
            .build();
    }
}
