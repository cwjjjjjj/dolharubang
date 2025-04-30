package com.dolharubang.domain.dto.response;

import com.dolharubang.domain.entity.Notification;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
@AllArgsConstructor
public class NotificationResDto {

    private Long id;
    private String title;
    private String content;
    private boolean isRead;
    private String type;
    private LocalDateTime createdAt;

    public static NotificationResDto from(Notification notification) {
        return NotificationResDto.builder()
            .id(notification.getId())
            .content(notification.getContent())
            .isRead(notification.isRead())
            .type(notification.getType().name())
            .createdAt(notification.getCreatedAt())
            .build();
    }
}
