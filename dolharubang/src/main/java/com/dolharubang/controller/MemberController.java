package com.dolharubang.controller;

import com.dolharubang.domain.dto.request.MemberReqDto;
import com.dolharubang.domain.dto.response.MemberResDto;
import com.dolharubang.service.MemberService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
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

    @Operation(summary = "모든 회원 조회하기")
    @GetMapping
    public ResponseEntity<List<MemberResDto>> getMember() {
        List<MemberResDto> response = memberService.getAllMembers();
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "회원 가입하기 (소셜로그인 아닌, 임시 방식)", description = "회원을 생성한다.")
    @PostMapping
    public ResponseEntity<MemberResDto> createMember(@RequestBody MemberReqDto memberReqDto) {
        MemberResDto response = memberService.createMember(memberReqDto);
        return ResponseEntity.ok(response);
    }
}
