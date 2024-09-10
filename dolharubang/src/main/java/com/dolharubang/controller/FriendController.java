package com.dolharubang.controller;

import com.dolharubang.domain.dto.request.FriendReqDto;
import com.dolharubang.domain.dto.response.FriendResDto;
import com.dolharubang.service.FriendService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
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
    @GetMapping("/{memberId}/list/accepted")
    public ResponseEntity<List<FriendResDto>> getAcceptedFriendList(@PathVariable Long memberId) {
        List<FriendResDto> friendList = friendService.getAcceptedFriendList(memberId);
        return ResponseEntity.ok(friendList);
    }

    @Operation(summary = "내가 보낸 친구 요청 목록 조회", description = "회원이 보낸 대기 중인 친구 요청 목록을 조회합니다.")
    @GetMapping("/{memberId}/list/sent")
    public ResponseEntity<List<FriendResDto>> getSentFriendRequests(@PathVariable Long memberId) {
        List<FriendResDto> sentRequests = friendService.getSentFriendRequests(memberId);
        return ResponseEntity.ok(sentRequests);
    }

    @Operation(summary = "내가 받은 친구 요청 목록 조회", description = "회원이 받은 대기 중인 친구 요청 목록을 조회합니다.")
    @GetMapping("/{memberId}/list/received")
    public ResponseEntity<List<FriendResDto>> getReceivedFriendRequests(
        @PathVariable Long memberId) {
        List<FriendResDto> receivedRequests = friendService.getReceivedFriendRequests(memberId);
        return ResponseEntity.ok(receivedRequests);
    }


    @Operation(summary = "친구 요청 생성", description = "새로운 친구 요청을 보냅니다.")
    @PostMapping("/request")
    public ResponseEntity<FriendResDto> sendFriendRequest(@RequestBody FriendReqDto friendReqDto) {
        FriendResDto response = friendService.sendFriendRequest(friendReqDto);
        return ResponseEntity.status(201).body(response); // 201 Created
    }

    @Operation(summary = "친구 요청 수락", description = "수신된 친구 요청을 수락합니다.")
    @PostMapping("/accept")
    public ResponseEntity<FriendResDto> acceptFriendRequest(
        @RequestParam Long requesterId, @RequestParam Long receiverId) {
        FriendResDto response = friendService.acceptFriendRequest(requesterId, receiverId);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "친구 요청 거절", description = "수신된 친구 요청을 거절합니다.")
    @PostMapping("/decline")
    public ResponseEntity<FriendResDto> declineFriendRequest(
        @RequestParam Long requesterId, @RequestParam Long receiverId) {
        FriendResDto response = friendService.declineFriendRequest(requesterId, receiverId);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "친구 관계 삭제", description = "수락된 친구 관계를 삭제합니다.")
    @DeleteMapping("/delete")
    public ResponseEntity<FriendResDto> deleteFriend(
        @RequestParam Long memberId, @RequestParam Long friendId) {
        FriendResDto response = friendService.deleteFriend(memberId, friendId);
        return ResponseEntity.ok(response);
    }
}
