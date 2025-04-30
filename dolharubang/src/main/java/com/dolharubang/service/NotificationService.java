package com.dolharubang.service;

import com.dolharubang.domain.dto.response.NotificationResDto;
import com.dolharubang.domain.entity.Notification;
import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
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

    public Page<NotificationResDto> getNotifications(Long memberId, int page, int size,
        boolean unreadOnly) {
        // 읽지 않은순 / 최신순
        Pageable pageable = PageRequest.of(page, size,
            Sort.by(Sort.Order.asc("isRead"), Sort.Order.desc("createdAt")));

        Page<Notification> pageResult;

        if (unreadOnly) {
            pageResult = notificationRepository.findByReceiverIdAndIsReadFalse(memberId, pageable);
        } else {
            pageResult = notificationRepository.findByReceiverId(memberId, pageable);
        }

        return pageResult.map(NotificationResDto::from);
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
