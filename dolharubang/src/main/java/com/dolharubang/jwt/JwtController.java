package com.dolharubang.jwt;

import com.dolharubang.domain.dto.oauth.OAuth2LoginResDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@Tag(name = "Jwt Token", description = "APIs for re-issuing tokens")
@RestController
@RequestMapping("api/v1/auth")
@RequiredArgsConstructor
public class JwtController {

    private final JwtService jwtService;

    @Operation(summary = "토큰 재발급 API", description = "리프레쉬 토큰을 검증한 후 액세스 토큰을 재발급합니다.")
    @PostMapping("/reissue")
    public ResponseEntity<OAuth2LoginResDto> reissue(
        @RequestHeader(value = "Authorization") String refreshToken) {
        //Bearer 접두사 삭제
        refreshToken = refreshToken.replace("Bearer ", "");
        return jwtService.reissue(refreshToken);
    }
}
