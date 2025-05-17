package com.dolharubang.domain.dto.response;

import com.dolharubang.domain.entity.Friend;
import com.dolharubang.domain.entity.Member;
import com.fasterxml.jackson.annotation.JsonProperty;
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

    public static FriendResDto fromEntity(Friend friend, Member me) {
        return FriendResDto.builder()
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
            .build();
    }
}
