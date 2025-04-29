package com.dolharubang.controller;

import com.dolharubang.domain.dto.response.FriendResDto;
import com.dolharubang.domain.entity.oauth.PrincipalDetails;
import com.dolharubang.service.FriendService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "Friends", description = "APIs for managing friends")
@RestController
@RequestMapping("/api/v1/friends")
@RequiredArgsConstructor
public class FriendController {

    private final FriendService friendService;

    @Operation(summary = "친구 목록 조회", description = "회원의 친구 목록을 조회합니다.")
    @GetMapping("/list/accepted")
    public ResponseEntity<?> getAcceptedFriendList(
        @AuthenticationPrincipal PrincipalDetails principal) {
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
        List<FriendResDto> friendList = friendService.getAcceptedFriendList(memberId);
        return ResponseEntity.ok(friendList);
    }

    @Operation(summary = "내가 보낸 친구 요청 목록 조회", description = "회원이 보낸 대기 중인 친구 요청 목록을 조회합니다.")
    @GetMapping("/list/sent")
    public ResponseEntity<?> getSentFriendRequests(
        @AuthenticationPrincipal PrincipalDetails principal) {
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
        List<FriendResDto> sentRequests = friendService.getSentFriendRequests(memberId);
        return ResponseEntity.ok(sentRequests);
    }

    @Operation(summary = "내가 받은 친구 요청 목록 조회", description = "회원이 받은 대기 중인 친구 요청 목록을 조회합니다.")
    @GetMapping("/list/received")
    public ResponseEntity<?> getReceivedFriendRequests(
        @AuthenticationPrincipal PrincipalDetails principal) {
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
        List<FriendResDto> receivedRequests = friendService.getReceivedFriendRequests(memberId);
        return ResponseEntity.ok(receivedRequests);
    }

    @PostMapping("/request")
    public ResponseEntity<?> sendFriendRequest(
        @AuthenticationPrincipal PrincipalDetails principal,
        @RequestParam Long receiverId
    ) {
        if (principal == null) {
            return ResponseEntity
                .status(HttpStatus.UNAUTHORIZED)
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of(
                    "code", "UNAUTHORIZED",
                    "message", "인증안댐"
                ));
        }

        Long requesterId = principal.getMember().getMemberId();
        FriendResDto response = friendService.sendFriendRequest(requesterId, receiverId);
        return ResponseEntity.status(201).body(response);
    }

    @Operation(summary = "친구 요청 수락", description = "수신된 친구 요청을 수락합니다.")
    @PostMapping("/accept")
    public ResponseEntity<?> acceptFriendRequest(
        @AuthenticationPrincipal PrincipalDetails principal,
        @RequestParam Long requesterId) {
        if (principal == null) {
            return ResponseEntity
                .status(HttpStatus.UNAUTHORIZED)
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of(
                    "code", "UNAUTHORIZED",
                    "message", "인증안댐"
                ));
        }

        Long receiverId = principal.getMember().getMemberId();
        FriendResDto response = friendService.acceptFriendRequest(requesterId, receiverId);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "친구 요청 거절", description = "수신된 친구 요청을 거절합니다.")
    @PostMapping("/decline")
    public ResponseEntity<?> declineFriendRequest(
        @AuthenticationPrincipal PrincipalDetails principal,
        @RequestParam Long requesterId) {
        if (principal == null) {
            return ResponseEntity
                .status(HttpStatus.UNAUTHORIZED)
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of(
                    "code", "UNAUTHORIZED",
                    "message", "인증안댐"
                ));
        }

        Long receiverId = principal.getMember().getMemberId();
        FriendResDto response = friendService.declineFriendRequest(requesterId, receiverId);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "친구 관계 삭제", description = "수락된 친구 관계를 삭제합니다.")
    @DeleteMapping("/delete")
    public ResponseEntity<?> deleteFriend(
        @AuthenticationPrincipal PrincipalDetails principal,
        @RequestParam Long friendId) {
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
        FriendResDto response = friendService.deleteFriend(memberId, friendId);
        return ResponseEntity.ok(response);
    }
}
