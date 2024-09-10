package com.dolharubang.domain.dto.request;

import com.dolharubang.domain.entity.Friend;
import com.dolharubang.domain.entity.Member;
import com.dolharubang.type.FriendStatusType;
import lombok.Getter;

@Getter
public class FriendReqDto {

    private Long requesterId;
    private Long receiverId;

    public static Friend toEntity(FriendReqDto dto, Member requester, Member receiver) {
        return Friend.builder()
            .requester(requester)
            .receiver(receiver)
            .status(FriendStatusType.PENDING)
            .build();
    }
}
