package com.dolharubang.controller;

import com.dolharubang.domain.dto.request.member.MemberInfoReqDto;
import com.dolharubang.domain.dto.request.member.MemberProfileReqDto;
import com.dolharubang.domain.dto.response.member.MemberProfileResDto;
import com.dolharubang.domain.dto.response.member.MemberResDto;
import com.dolharubang.domain.dto.response.member.MemberSearchResDto;
import com.dolharubang.domain.entity.oauth.PrincipalDetails;
import com.dolharubang.service.MemberService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
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
    public ResponseEntity<MemberResDto> getMember(@AuthenticationPrincipal PrincipalDetails principal) {
        Long memberId = principal.getMember().getMemberId();
        MemberResDto response = memberService.getMember(memberId);

        return ResponseEntity.ok(response);
    }

    @Operation(summary = "회원 프로필 조회하기")
    @GetMapping("/profile")
    public ResponseEntity<MemberProfileResDto> getMemberProfile(@AuthenticationPrincipal PrincipalDetails principal) {
        Long memberId = principal.getMember().getMemberId();
        MemberProfileResDto response = memberService.getMemberProfile(memberId);

        return ResponseEntity.ok(response);
    }

    @Operation(summary = "프로필 회원 정보 수정하기", description = "닉네임, 공간 이름 수정한다.")
    @PostMapping("/profile")
    public ResponseEntity<MemberProfileResDto> updateMember(@AuthenticationPrincipal PrincipalDetails principal,
        @RequestBody MemberProfileReqDto memberReqDto) {
        Long memberId = principal.getMember().getMemberId();
        MemberProfileResDto response = memberService.updateMemberProfile(memberId, memberReqDto);

        return ResponseEntity.ok(response);
    }

    @Operation(summary = "회원가입 시 정보 입력하기", description = "닉네임, 생일 입력한다.")
    @PostMapping("/member-info")
    public ResponseEntity<MemberProfileResDto> addMemberInfo(@AuthenticationPrincipal PrincipalDetails principal,
        @RequestBody MemberInfoReqDto memberReqDto) {
        Long memberId = principal.getMember().getMemberId();
        MemberProfileResDto response = memberService.addMemberInfo(memberId, memberReqDto);

        return ResponseEntity.ok(response);
    }

    @Operation(summary = "프로필 사진 수정하기", description = "base64 string으로 프로필 사진을 수정한다.")
    @PostMapping("/profile-picture")
    public ResponseEntity<MemberProfileResDto> updateProfilePicture(@AuthenticationPrincipal PrincipalDetails principal,
        @RequestBody String imageBase64) {
        Long memberId = principal.getMember().getMemberId();
        MemberProfileResDto response = memberService.updateMemberProfilePicture(memberId, imageBase64);

        return ResponseEntity.ok(response);
    }

    @Operation(summary = "회원 모래알 조회하기", description = "모래알을 조회한다.")
    @GetMapping("/sands")
    public int getSands(@AuthenticationPrincipal PrincipalDetails principal) {
        Long memberId = principal.getMember().getMemberId();
        return memberService.getSands(memberId);
    }

    @Operation(summary = "회원 검색하기", description = "닉네임 기준으로 회원을 검색한다.")
    @GetMapping("/search")
    public ResponseEntity<List<MemberSearchResDto>> searchMember(String keyword) {
        List<MemberSearchResDto> response = memberService.searchMember(keyword);
        return ResponseEntity.ok(response);
    }
}
