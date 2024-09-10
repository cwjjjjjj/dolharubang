package com.dolharubang.domain.dto.response;

import com.dolharubang.domain.entity.Friend;
import java.time.LocalDateTime;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Builder
@Getter
@Setter
@ToString
public class FriendResDto {

    private Long requesterId;
    private Long receiverId;
    private String status;
    private LocalDateTime acceptedAt;
    private LocalDateTime createdAt;
    private LocalDateTime modifiedAt;
    private LocalDateTime deletedAt;

    public static FriendResDto fromEntity(Friend friend) {
        return FriendResDto.builder()
            .requesterId(friend.getRequester().getMemberId())
            .receiverId(friend.getReceiver().getMemberId())
            .status(friend.getStatus().name())
            .acceptedAt(friend.getAcceptedAt())
            .createdAt(friend.getCreatedAt())
            .modifiedAt(friend.getModifiedAt())
            .deletedAt(friend.getDeletedAt())
            .build();
    }
}
