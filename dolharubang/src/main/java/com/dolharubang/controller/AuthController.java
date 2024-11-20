package com.dolharubang.controller;

import com.dolharubang.domain.dto.request.SignInReqDto;
import com.dolharubang.domain.dto.response.SignInResDto;
import com.dolharubang.service.AuthService;
import java.security.Principal;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RequiredArgsConstructor
@RequestMapping("/api/v1/auth")
@RestController
public class AuthController {

    private final AuthService authService;

    @PostMapping
    public ResponseEntity<SignInResDto> signIn(@RequestHeader("Authorization") String socialAccessToken,
        @RequestBody SignInReqDto reqDto) {
        SignInResDto response = authService.signIn(socialAccessToken, reqDto);
        //TODO return 값 수정 필요
        return ResponseEntity.ok(response);
    }

    @PostMapping("/logout")
    public ResponseEntity<Void> singOut(Principal principal) {
        Long memberId = Long.parseLong(principal.getName());
        authService.signOut(memberId);
        return ResponseEntity.ok(null);
    }

}
