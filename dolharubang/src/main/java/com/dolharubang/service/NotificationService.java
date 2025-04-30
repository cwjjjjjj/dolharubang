package com.dolharubang.service;

import com.dolharubang.domain.dto.response.NotificationResDto;
import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.Notification;
import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import com.dolharubang.repository.MemberRepository;
import com.dolharubang.repository.NotificationRepository;
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

    public void markAsRead(Long memberId, Long notificationId) {
        Notification notification = notificationRepository.findByIdAndReceiverId(notificationId,
                memberId)
            .orElseThrow(() -> new CustomException(ErrorCode.NOTIFICATION_NOT_FOUND));
        notification.markAsRead();
        notificationRepository.save(notification);
    }
}
