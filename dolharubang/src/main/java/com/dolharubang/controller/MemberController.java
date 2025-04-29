package com.dolharubang.controller;

import com.dolharubang.domain.dto.request.member.MemberInfoReqDto;
import com.dolharubang.domain.dto.request.member.MemberProfileReqDto;
import com.dolharubang.domain.dto.response.member.MemberProfileResDto;
import com.dolharubang.domain.dto.response.member.MemberResDto;
import com.dolharubang.domain.dto.response.member.MemberSearchResDto;
import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.oauth.PrincipalDetails;
import com.dolharubang.service.MemberService;
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
@Tag(name = "Members", description = "APIs for managing members")
@RestController
@RequestMapping("/api/v1/members")
public class MemberController {

    private final MemberService memberService;

    public MemberController(MemberService memberService) {
        this.memberService = memberService;
    }

    @Operation(summary = "회원 조회하기")
    @GetMapping("")
    public ResponseEntity<?> getMember(@AuthenticationPrincipal PrincipalDetails principal) {
        if (principal == null) {
            return ResponseEntity
                .status(HttpStatus.UNAUTHORIZED)
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of(
                    "code", "UNAUTHORIZED",
                    "message", "인증에 실패햐였습니다"
                ));
        }
        Long memberId = getMemberId(principal);
        MemberResDto response = memberService.getMember(memberId);

        return ResponseEntity.ok(response);
    }

    @Operation(summary = "회원 프로필 조회하기")
    @GetMapping("/profile")
    public ResponseEntity<?> getMemberProfile(@AuthenticationPrincipal PrincipalDetails principal) {
        if (principal == null) {
            return ResponseEntity
                .status(HttpStatus.UNAUTHORIZED)
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of(
                    "code", "UNAUTHORIZED",
                    "message", "인증에 실패햐였습니다"
                ));
        }
        Long memberId = getMemberId(principal);
        MemberProfileResDto response = memberService.getMemberProfile(memberId);

        return ResponseEntity.ok(response);
    }

    @Operation(summary = "프로필 회원 정보 수정하기", description = "닉네임, 공간 이름 수정한다.")
    @PostMapping("/profile")
    public ResponseEntity<?> updateMember(@AuthenticationPrincipal PrincipalDetails principal,
        @RequestBody MemberProfileReqDto memberReqDto) {
        if (principal == null) {
            return ResponseEntity
                .status(HttpStatus.UNAUTHORIZED)
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of(
                    "code", "UNAUTHORIZED",
                    "message", "인증에 실패햐였습니다"
                ));
        }
        Long memberId = getMemberId(principal);
        MemberProfileResDto response = memberService.updateMemberProfile(memberId, memberReqDto);

        return ResponseEntity.ok(response);
    }

    @Operation(summary = "회원가입 시 정보 입력하기", description = "닉네임, 생일 입력한다.")
    @PostMapping("/member-info")
    public ResponseEntity<?> addMemberInfo(@AuthenticationPrincipal PrincipalDetails principal,
        @RequestBody MemberInfoReqDto memberReqDto) {
        if (principal == null) {
            return ResponseEntity
                .status(HttpStatus.UNAUTHORIZED)
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of(
                    "code", "UNAUTHORIZED",
                    "message", "인증에 실패햐였습니다"
                ));
        }
        Long memberId = getMemberId(principal);
        MemberProfileResDto response = memberService.addMemberInfo(memberId, memberReqDto);

        return ResponseEntity.ok(response);
    }

    @Operation(summary = "프로필 사진 수정하기", description = "base64 string으로 프로필 사진을 수정한다.")
    @PostMapping("/profile-picture")
    public ResponseEntity<?> updateProfilePicture(@AuthenticationPrincipal PrincipalDetails principal,
        @RequestBody String imageBase64) {
        if (principal == null) {
            return ResponseEntity
                .status(HttpStatus.UNAUTHORIZED)
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of(
                    "code", "UNAUTHORIZED",
                    "message", "인증에 실패햐였습니다"
                ));
        }
        Long memberId = getMemberId(principal);
        MemberProfileResDto response = memberService.updateMemberProfilePicture(memberId, imageBase64);

        return ResponseEntity.ok(response);
    }

    @Operation(summary = "회원 모래알 조회하기", description = "모래알을 조회한다.")
    @GetMapping("/sands")
    public ResponseEntity<?> getSands(@AuthenticationPrincipal PrincipalDetails principal) {
        if (principal == null) {
            return ResponseEntity
                .status(HttpStatus.UNAUTHORIZED)
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of(
                    "code", "UNAUTHORIZED",
                    "message", "인증에 실패햐였습니다"
                ));
        }
        Long memberId = getMemberId(principal);
        return ResponseEntity.ok(memberService.getSands(memberId));
    }

    @Operation(summary = "회원 검색하기", description = "닉네임 기준으로 회원을 검색한다.")
    @GetMapping("/search")
    public ResponseEntity<List<MemberSearchResDto>> searchMember(String keyword) {
        List<MemberSearchResDto> response = memberService.searchMember(keyword);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "닉네임 중복 검사하기", description = "같은 닉네임의 회원이 없다면 true 반환한다.")
    @GetMapping("/check/{keyword}")
    public ResponseEntity<Boolean> checkNickname(@PathVariable String keyword) {
        boolean isUnique = memberService.checkNickname(keyword);
        return ResponseEntity.ok(isUnique);
    }

    @Operation(summary = "신규 회원 여부 조회하기", description = "신규 회원이라면 true를 반환한다.")
    @GetMapping("/is-first")
    public ResponseEntity<?> isFirst(@AuthenticationPrincipal PrincipalDetails principal) {
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
        return ResponseEntity.ok(memberService.isStoneEmpty(member));
    }

    private static Long getMemberId(PrincipalDetails principal) {
        return principal.getMember().getMemberId();
    }

}
