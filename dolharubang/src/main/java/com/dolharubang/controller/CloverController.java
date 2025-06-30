package com.dolharubang.controller;

import com.dolharubang.domain.dto.request.CloverReqDto;
import com.dolharubang.domain.dto.response.CloverResDto;
import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.oauth.PrincipalDetails;
import com.dolharubang.service.CloverService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;
import java.util.Map;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@Tag(name = "Clovers", description = "APIs for managing clovers")
@RestController
@RequestMapping("/api/v1/clovers")
public class CloverController {

    private final CloverService cloverService;

    public CloverController(CloverService cloverService) {
        this.cloverService = cloverService;
    }

    @Operation(summary = "클로버 조회하기", description = "cloverId 기준으로 조회, API 테스트용")
    @GetMapping("/{id}")
    public ResponseEntity<CloverResDto> getClover (@PathVariable Long id) {
        CloverResDto response = cloverService.getClover(id);

        return ResponseEntity.status(HttpStatus.OK).body(response);
    }

    @Operation(summary = "클로버 보내기", description = "특정 회원에게 클로버를 보낸다.")
    @PostMapping("/send")
    public ResponseEntity<?> sendClover(@AuthenticationPrincipal PrincipalDetails principal,
                                        @RequestBody CloverReqDto reqDto) {

        if (principal == null) {
            return ResponseEntity
                    .status(HttpStatus.UNAUTHORIZED)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(Map.of(
                            "code", "UNAUTHORIZED",
                            "message", "인증에 실패하였습니다"
                    ));
        }

        Member sendingMember = principal.getMember();
        CloverResDto response = cloverService.createClover(sendingMember, reqDto);

        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @Operation(summary = "내가 보낸 클로버 리스트 조회", description = "보낸 클로버 전체 조회, API 테스트용")
    @GetMapping("/sent")
    public ResponseEntity<?> getSentCloverList(@AuthenticationPrincipal PrincipalDetails principal) {
        if (principal == null) {
            return ResponseEntity
                    .status(HttpStatus.UNAUTHORIZED)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(Map.of(
                            "code", "UNAUTHORIZED",
                            "message", "인증에 실패하였습니다"
                    ));
        }
        Member member = principal.getMember();

        List<CloverResDto> response = cloverService.getSentCloverList(member);
        return ResponseEntity.status(HttpStatus.OK).body(response);
    }

    @Operation(summary = "내가 받은 클로버 리스트 조회", description = "받은 클로버 전체 조회, API 테스트용")
    @GetMapping("/received")
    public ResponseEntity<?> getReceivedCloverList(@AuthenticationPrincipal PrincipalDetails principal) {
        if (principal == null) {
            return ResponseEntity
                    .status(HttpStatus.UNAUTHORIZED)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(Map.of(
                            "code", "UNAUTHORIZED",
                            "message", "인증에 실패하였습니다"
                    ));
        }
        Member member = principal.getMember();

        List<CloverResDto> response = cloverService.getReceivedCloverList(member);
        return ResponseEntity.status(HttpStatus.OK).body(response);
    }
}
