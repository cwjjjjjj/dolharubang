package com.dolharubang.domain.event;

import com.dolharubang.type.FriendActionType;
import java.time.LocalDate;

public record FriendEvent(Long memberId, FriendActionType actionType, LocalDate date) {

}
