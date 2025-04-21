package com.dolharubang.controller;

import com.dolharubang.domain.dto.request.StoneReqDto;
import com.dolharubang.domain.dto.request.StoneTextUpdateReqDto;
import com.dolharubang.domain.dto.response.stone.StoneProfileResDto;
import com.dolharubang.domain.dto.response.stone.StoneResDto;
import com.dolharubang.domain.entity.oauth.PrincipalDetails;
import com.dolharubang.service.StoneService;
import com.dolharubang.type.AbilityType;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.HashMap;
import java.util.Map;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
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
    public ResponseEntity<StoneResDto> addStone(@AuthenticationPrincipal PrincipalDetails principal,
        @RequestBody StoneReqDto requestDto,
        String spaceName) {
        StoneResDto response = stoneService.adoptStone(requestDto, spaceName);

        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @Operation(summary = "돌 프로필 조회하기", description = "보유한 돌의 정보를 조회한다.")
    @GetMapping("/profile")
    public ResponseEntity<StoneProfileResDto> readStoneProfile(
        @AuthenticationPrincipal PrincipalDetails principal) {
        Long memberId = principal.getMember().getMemberId();
        StoneProfileResDto response = stoneService.getStoneProfile(memberId);

        return ResponseEntity.status(HttpStatus.OK).body(response);
    }

    @Operation(summary = "돌 이름 수정하기", description = "소유한 돌의 이름을 수정한다.")
    @PostMapping("/name")
    public Map<String, String> updateStoneName(@AuthenticationPrincipal PrincipalDetails principal,
        @RequestBody StoneTextUpdateReqDto dto) {
        Long memberId = principal.getMember().getMemberId();
        Map<String, String> response = new HashMap<>();
        response.put("stoneName", stoneService.updateStoneName(memberId, dto));

        return response;
    }

    @Operation(summary = "팻말 문구 조회하기", description = "팻말 문구의 내용을 조회한다.")
    @GetMapping(path = "/sign-text", produces = "application/json")
    public Map<String, String> readSignText(@AuthenticationPrincipal PrincipalDetails principal) {
        Long memberId = principal.getMember().getMemberId();
        Map<String, String> response = new HashMap<>();
        response.put("signText", stoneService.readSignText(memberId));

        return response;
    }

    @Operation(summary = "팻말 문구 수정하기", description = "팻말 문구을 수정한다.")
    @PostMapping("/sign-text")
    public Map<String, String> updateSignText(@AuthenticationPrincipal PrincipalDetails principal,
        @RequestBody StoneTextUpdateReqDto dto) {
        Long memberId = principal.getMember().getMemberId();
        Map<String, String> response = new HashMap<>();
        response.put("signText", stoneService.updateSignText(memberId, dto));

        return response;
    }

    @Operation(summary = "잠재능력 조회하기", description = "잠재능력의 획득/미획득 여부를 조회한다.")
    @PostMapping("/ability")
    public Map<AbilityType, Boolean> readAbilityAble(
        @AuthenticationPrincipal PrincipalDetails principal) {
        Long memberId = principal.getMember().getMemberId();
        return stoneService.readAbilityAble(memberId);
    }

    @Operation(summary = "잠재능력 획득하기", description = "하나의 잠재능력 획득 여부를 true로 변경한다.")
    @PostMapping("/obtain/ability")
    public Map<AbilityType, Boolean> getAbilityAble(
        @AuthenticationPrincipal PrincipalDetails principal,
        @RequestParam AbilityType abilityType) {
        Long memberId = principal.getMember().getMemberId();
        return stoneService.updateAbilityAble(memberId, abilityType);
    }
}
