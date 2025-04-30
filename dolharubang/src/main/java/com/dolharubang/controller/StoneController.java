package com.dolharubang.controller;

import com.dolharubang.domain.dto.request.StoneReqDto;
import com.dolharubang.domain.dto.request.StoneTextUpdateReqDto;
import com.dolharubang.domain.dto.response.stone.StoneHomeResDto;
import com.dolharubang.domain.dto.response.stone.StoneProfileResDto;
import com.dolharubang.domain.dto.response.stone.StoneResDto;
import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.oauth.PrincipalDetails;
import com.dolharubang.service.StoneService;
import com.dolharubang.type.AbilityType;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.HashMap;
import java.util.Map;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@Tag(name = "stones", description = "APIs for managing stones")
@RestController
@RequestMapping("/api/v1/stones")
public class StoneController {

    private final StoneService stoneService;

    public StoneController(StoneService stoneService) {
        this.stoneService = stoneService;
    }

    @Operation(summary = "돌 입양하기", description = "돌을 입양한다.")
    @PostMapping("/adopt")
    public ResponseEntity<?> addStone(@AuthenticationPrincipal PrincipalDetails principal,
        @RequestBody StoneReqDto requestDto,
        @RequestBody String spaceName) {
        if (principal == null) {
            return ResponseEntity
                .status(HttpStatus.UNAUTHORIZED)
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of(
                    "code", "UNAUTHORIZED",
                    "message", "인증에 실패햐였습니다"
                ));
        }
        Member member = principal.getMember();
        StoneResDto response = stoneService.adoptStone(member, requestDto, spaceName);

        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @Operation(summary = "돌 프로필 조회하기", description = "보유한 돌의 정보를 조회한다.")
    @GetMapping("/profile")
    public ResponseEntity<?> readStoneProfile(
        @AuthenticationPrincipal PrincipalDetails principal) {
        if (principal == null) {
            return ResponseEntity
                .status(HttpStatus.UNAUTHORIZED)
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of(
                    "code", "UNAUTHORIZED",
                    "message", "인증에 실패햐였습니다"
                ));
        }
        Long memberId = findMemberId(principal);
        StoneProfileResDto response = stoneService.getStoneProfile(memberId);

        return ResponseEntity.status(HttpStatus.OK).body(response);
    }

    @Operation(summary = "돌 이름 수정하기", description = "소유한 돌의 이름을 수정한다.")
    @PostMapping("/name")
    public ResponseEntity<?> updateStoneName(@AuthenticationPrincipal PrincipalDetails principal,
        @RequestBody StoneTextUpdateReqDto dto) {

        if (principal == null) {
            return ResponseEntity
                .status(HttpStatus.UNAUTHORIZED)
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of(
                    "code", "UNAUTHORIZED",
                    "message", "인증에 실패햐였습니다"
                ));
        }
        Long memberId = findMemberId(principal);
        StoneProfileResDto response = stoneService.updateStoneName(memberId, dto);

        return ResponseEntity.status(HttpStatus.OK).body(response);
    }

    @Operation(summary = "팻말 문구 조회하기", description = "팻말 문구의 내용을 조회한다.")
    @GetMapping(path = "/sign-text", produces = "application/json")
    public ResponseEntity<?> readSignText(@AuthenticationPrincipal PrincipalDetails principal) {

        if (principal == null) {
            return ResponseEntity
                .status(HttpStatus.UNAUTHORIZED)
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of(
                    "code", "UNAUTHORIZED",
                    "message", "인증에 실패햐였습니다"
                ));
        }

        Long memberId = findMemberId(principal);
        Map<String, String> response = new HashMap<>();
        response.put("signText", stoneService.readSignText(memberId));

        return ResponseEntity.status(HttpStatus.OK).body(response);
    }

    @Operation(summary = "홈화면의 돌 정보 및 편지 수 조회하기", description = "홈화면의 돌 정보 및 편지 수 조회한다.")
    @GetMapping(path = "/stone-info", produces = "application/json")
    public ResponseEntity<?> getStoneHomeInfo(@AuthenticationPrincipal PrincipalDetails principal) {
        if (principal == null) {
            return ResponseEntity
                .status(HttpStatus.UNAUTHORIZED)
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of(
                    "code", "UNAUTHORIZED",
                    "message", "인증에 실패햐였습니다"
                ));
        }

        Long memberId = findMemberId(principal);
        StoneHomeResDto response = stoneService.getStoneHomeInfo(memberId);

        return ResponseEntity.status(HttpStatus.OK).body(response);
    }

    @Operation(summary = "팻말 문구 수정하기", description = "팻말 문구을 수정한다.")
    @PostMapping("/sign-text")
    public ResponseEntity<?> updateSignText(@AuthenticationPrincipal PrincipalDetails principal,
        @RequestBody StoneTextUpdateReqDto dto) {

        if (principal == null) {
            return ResponseEntity
                .status(HttpStatus.UNAUTHORIZED)
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of(
                    "code", "UNAUTHORIZED",
                    "message", "인증에 실패햐였습니다"
                ));
        }

        Long memberId = findMemberId(principal);
        Map<String, String> response = new HashMap<>();
        response.put("signText", stoneService.updateSignText(memberId, dto));

        return ResponseEntity.status(HttpStatus.OK).body(response);
    }

    @Operation(summary = "잠재능력 조회하기", description = "잠재능력의 획득/미획득 여부를 조회한다.")
    @GetMapping("/ability")
    public ResponseEntity<?> readAbilityAble(
        @AuthenticationPrincipal PrincipalDetails principal) {
        if (principal == null) {
            return ResponseEntity
                .status(HttpStatus.UNAUTHORIZED)
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of(
                    "code", "UNAUTHORIZED",
                    "message", "인증에 실패햐였습니다"
                ));
        }

        Long memberId = findMemberId(principal);
        Map<AbilityType, Boolean> response = stoneService.readAbilityAble(memberId);
        return ResponseEntity.status(HttpStatus.OK).body(response);
    }

    @Operation(summary = "잠재능력 획득하기", description = "하나의 잠재능력 획득 여부를 true로 변경한다.")
    @PostMapping("/obtain/ability")
    public ResponseEntity<?> getAbilityAble(
        @AuthenticationPrincipal PrincipalDetails principal,
        @RequestParam AbilityType abilityType) {
        if (principal == null) {
            return ResponseEntity
                .status(HttpStatus.UNAUTHORIZED)
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of(
                    "code", "UNAUTHORIZED",
                    "message", "인증에 실패햐였습니다"
                ));
        }
        Long memberId = findMemberId(principal);
        Map<AbilityType, Boolean> response = stoneService.updateAbilityAble(memberId, abilityType);

        return ResponseEntity.status(HttpStatus.OK).body(response);
    }

    private static Long findMemberId(PrincipalDetails principal) {
        return principal.getMember().getMemberId();
    }
}
