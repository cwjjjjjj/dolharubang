package com.dolharubang.controller;

import com.dolharubang.domain.dto.request.MemberReqDto;
import com.dolharubang.domain.dto.response.MemberResDto;
import com.dolharubang.service.MemberService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
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

    @Operation(description = "회원을 생성한다.")
    @PostMapping
    public ResponseEntity<MemberResDto> createMember(@RequestBody MemberReqDto memberReqDto) {
        MemberResDto response = memberService.createMember(memberReqDto);
        return ResponseEntity.ok(response);
    }
}
