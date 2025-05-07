package com.dolharubang.controller;

import com.dolharubang.domain.dto.response.NotificationResDto;
import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.oauth.PrincipalDetails;
import com.dolharubang.service.NotificationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/notifications")
@Tag(name = "notifications", description = "APIs for managing notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    @Operation(summary = "알림 목록 조회", description = "회원의 알림 목록을 조회합니다.")
    @GetMapping
    public ResponseEntity<?> getNotifications(
        @AuthenticationPrincipal PrincipalDetails principal,
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "20") int size,
        @RequestParam(defaultValue = "false") boolean unreadOnly) {

        if (principal == null) {
            return ResponseEntity
                .status(HttpStatus.UNAUTHORIZED)
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of(
                    "code", "UNAUTHORIZED",
                    "message", "인증안댐"
                ));
        }

        Member member = principal.getMember();
        Page<NotificationResDto> notifications = notificationService.getNotifications(member,
            page, size, unreadOnly);

        return ResponseEntity.ok(notifications.getContent());
    }

    @Operation(summary = "읽지 않은 알림 수 조회", description = "회원의 읽지 않은 알림 개수를 반환합니다.")
    @GetMapping("/unread-count")
    public ResponseEntity<?> getUnreadCount(@AuthenticationPrincipal PrincipalDetails principal) {
        if (principal == null) {
            return ResponseEntity
                .status(HttpStatus.UNAUTHORIZED)
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of(
                    "code", "UNAUTHORIZED",
                    "message", "인증안댐"
                ));
        }

        Long memberId = principal.getMember().getMemberId();
        long count = notificationService.getUnreadCount(memberId);
        return ResponseEntity.ok(Map.of("unreadCount", count));
    }

    @Operation(summary = "알림 읽음 처리", description = "특정 알림을 읽음 처리합니다.")
    @PostMapping("/{id}/read")
    public ResponseEntity<?> markAsRead(
        @AuthenticationPrincipal PrincipalDetails principal,
        @PathVariable Long id) {
        if (principal == null) {
            return ResponseEntity
                .status(HttpStatus.UNAUTHORIZED)
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of(
                    "code", "UNAUTHORIZED",
                    "message", "인증안댐"
                ));
        }

        Member member = principal.getMember();
        NotificationResDto updatedNotification = notificationService.markAsRead(
            member.getMemberId(), id);

        return ResponseEntity.ok(updatedNotification);
    }

}
