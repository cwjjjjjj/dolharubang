package com.dolharubang.domain.dto.response;

import com.dolharubang.domain.entity.Friend;
import com.dolharubang.domain.entity.Member;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import java.time.LocalDateTime;

@Builder
@Getter
@Setter
@ToString
public class FriendWithCloverResDto {

    private Long id;
    private String requesterNickname;
    private String receiverNickname;
    private String requesterProfileImageURL;
    private String receiverProfileImageURL;
    @JsonProperty("isSender")
    private boolean isSender;
    private String requesterSpaceName;
    private String receiverSpaceName;
    private LocalDateTime acceptedAt;
    private LocalDateTime modifiedAt;
    private boolean isSentCloverToday;

    public static FriendWithCloverResDto fromEntity(Friend friend, Member me, boolean isSentCloverToday) {
        return FriendWithCloverResDto.builder()
                .id(me.getMemberId().equals(friend.getRequester().getMemberId()) ? friend.getReceiver()
                        .getMemberId() : friend.getRequester().getMemberId())
                .requesterNickname(friend.getRequester().getNickname())
                .receiverNickname(friend.getReceiver().getNickname())
                .requesterProfileImageURL(friend.getRequester().getProfilePicture())
                .receiverProfileImageURL(friend.getReceiver().getProfilePicture())
                .isSender(friend.getRequester().getMemberId().equals(me.getMemberId()))
                .requesterSpaceName(friend.getRequester().getSpaceName())
                .receiverSpaceName(friend.getReceiver().getSpaceName())
                .acceptedAt(friend.getAcceptedAt())
                .modifiedAt(friend.getModifiedAt())
                .isSentCloverToday(isSentCloverToday)
                .build();
    }
}
