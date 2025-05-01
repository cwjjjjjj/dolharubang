package com.dolharubang.service;

import com.dolharubang.domain.dto.response.NotificationResDto;
import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.Notification;
import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import com.dolharubang.repository.MemberRepository;
import com.dolharubang.repository.NotificationRepository;
import com.dolharubang.type.NotificationType;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final MemberRepository memberRepository;

    public Page<NotificationResDto> getNotifications(Member member, int page, int size,
        boolean unreadOnly) {
        Pageable pageable = PageRequest.of(page, size,
            Sort.by(Sort.Order.asc("isRead"), Sort.Order.desc("createdAt")));

        Page<Notification> pageResult = unreadOnly
            ? notificationRepository.findByReceiverIdAndIsReadFalse(member.getMemberId(), pageable)
            : notificationRepository.findByReceiverId(member.getMemberId(), pageable);

        return pageResult.map(
            notification -> NotificationResDto.from(notification, member.getNickname()));
    }


    public long getUnreadCount(Long memberId) {
        return notificationRepository.countByReceiverIdAndIsReadFalse(memberId);
    }

    public NotificationResDto markAsRead(Long memberId, Long notificationId, String nickname) {
        Notification notification = notificationRepository.findByIdAndReceiverId(notificationId,
                memberId)
            .orElseThrow(() -> new CustomException(ErrorCode.NOTIFICATION_NOT_FOUND));

        notification.markAsRead();
        notificationRepository.save(notification); // 변경사항 반영

        return NotificationResDto.from(notification, nickname);
    }

    // 친구 요청시 알림
    public void sendFriendRequestNotification(Member receiver, Member requester) {
        Notification notification = Notification.builder()
            .receiverId(receiver.getMemberId())
            .content(requester.getNickname() + "님이 친구 요청을 보냈어요.")
            .type(NotificationType.FRIEND_REQUEST)
            .isRead(false)
            .build();

        notificationRepository.save(notification);
    }

    // 친구 요청이 수락 되었을 때
    public void sendFriendAcceptedNotification(Member requester, Member receiver) {
        // 수락한 B → A에게 알림
        Notification toRequester = Notification.builder()
            .receiverId(requester.getMemberId())
            .content(receiver.getNickname() + "님과 친구가 되었어요!")
            .type(NotificationType.FRIEND_ACCEPTED)
            .isRead(false)
            .build();

        // 요청했던 A → 수락한 B에게 알림
        Notification toReceiver = Notification.builder()
            .receiverId(receiver.getMemberId())
            .content(requester.getNickname() + "님과 친구가 되었어요!")
            .type(NotificationType.FRIEND_ACCEPTED)
            .isRead(false)
            .build();

        notificationRepository.save(toRequester);
        notificationRepository.save(toReceiver);
    }


}
