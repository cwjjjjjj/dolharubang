package com.dolharubang.controller;

import com.dolharubang.domain.dto.request.MemberProfileReqDto;
import com.dolharubang.domain.dto.request.MemberReqDto;
import com.dolharubang.domain.dto.response.member.MemberProfileResDto;
import com.dolharubang.domain.dto.response.member.MemberResDto;
import com.dolharubang.service.MemberService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
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

    @Operation(summary = "모든 회원 조회하기")
    @GetMapping("/all-members")
    public ResponseEntity<List<MemberResDto>> getAllMembers() {
        List<MemberResDto> response = memberService.getAllMembers();
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "회원 조회하기")
    @GetMapping("/{id}")
    public ResponseEntity<MemberResDto> getMember(@PathVariable Long id) {
        MemberResDto response = memberService.getMember(id);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "회원 프로필 조회하기")
    @GetMapping("/profile/{id}")
    public ResponseEntity<MemberProfileResDto> getMemberProfile(@PathVariable Long id) {
        MemberProfileResDto response = memberService.getMemberProfile(id);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "회원 가입하기 (소셜로그인 아닌, 임시 방식)", description = "회원을 생성한다.")
    @PostMapping
    public ResponseEntity<MemberResDto> createMember(@RequestBody MemberReqDto memberReqDto) {
        MemberResDto response = memberService.createMember(memberReqDto);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "프로필 회원 정보 수정하기", description = "닉네임, 공간 이름 수정한다.")
    @PostMapping("/profile/{id}")
    public ResponseEntity<MemberProfileResDto> updateMember(@PathVariable Long id,
        @RequestBody MemberProfileReqDto memberReqDto) {
        MemberProfileResDto response = memberService.updateMemberProfile(id, memberReqDto);

        return ResponseEntity.ok(response);
    }

    @Operation(summary = "프로필 사진 수정하기", description = "base64 string으로 프로필 사진을 수정한다.")
    @PostMapping("/profile-picture/{id}")
    public ResponseEntity<MemberProfileResDto> updateProfilePicture(@PathVariable Long id,
        @RequestBody String imageBase64) {
        MemberProfileResDto response = memberService.updateMemberProfilePicture(id, imageBase64);

        return ResponseEntity.ok(response);
    }

    @Operation(summary = "회원 모래알 조회하기", description = "모래알을 조회한다.")
    @GetMapping("/sands/{memberId}")
    public int getSands(@PathVariable Long memberId) {
        return memberService.getSands(memberId);
    }
}
