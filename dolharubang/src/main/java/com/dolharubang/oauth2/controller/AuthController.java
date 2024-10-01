package com.dolharubang.oauth2.controller;

import com.dolharubang.config.properties.AppProperties;
import com.dolharubang.domain.entity.MemberRefreshToken;
import com.dolharubang.oauth2.ApiResponse;
import com.dolharubang.oauth2.util.CookieUtils;
import com.dolharubang.oauth2.util.HeaderUtils;
import com.dolharubang.oauth2.model.Role;
import com.dolharubang.oauth2.token.AuthTokenProvider;
import com.dolharubang.repository.MemberRefreshTokenRepository;
import io.jsonwebtoken.Claims;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.dolharubang.oauth2.token.AuthToken;
import java.util.Date;
import jakarta.servlet.http.Cookie;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AppProperties appProperties;
    private final AuthTokenProvider tokenProvider;
    private final MemberRefreshTokenRepository memberRefreshTokenRepository;

    private final static long THREE_DAYS_MSEC = 259200000;
    private final static String REFRESH_TOKEN = "refresh_token";

    @GetMapping("/refresh")
    public ApiResponse refreshToken(HttpServletRequest request, HttpServletResponse response) {
        // accessToken 확인
        String accessToken = HeaderUtils.getAccessToken(request);
        AuthToken authToken = tokenProvider.convertAuthToken(accessToken);

        // access token 유효성 검사 (비활성화된 코드 예시 주석 처리)
        // if (!authToken.validate()) {
        //     return ApiResponse.invalidAccessToken();
        // }

        // expired access token 확인
        Claims claims = authToken.getExpiredTokenClaims();
        if (claims == null) {
            return ApiResponse.notExpiredTokenYet();
        }

        String userId = claims.getSubject();
        Role role = Role.of(claims.get("role", String.class));

        // refresh Token 확인
        String refreshToken = CookieUtils.getCookie(request, REFRESH_TOKEN)
            .map(Cookie::getValue)
            .orElse(null);
        AuthToken authRefreshToken = tokenProvider.convertAuthToken(refreshToken);

        if (!authRefreshToken.validate()) {
            return ApiResponse.invalidRefreshToken();
        }

        // userId와 refreshToken으로 DB에서 토큰 확인
        Optional<MemberRefreshToken> memberRefreshTokenOpt = memberRefreshTokenRepository.findByMemberIdAndRefreshToken(userId, refreshToken);
        if (memberRefreshTokenOpt.isEmpty()) {
            return ApiResponse.invalidRefreshToken();
        }

        MemberRefreshToken memberRefreshToken = memberRefreshTokenOpt.get();

        Date now = new Date();
        AuthToken newAccessToken = tokenProvider.createAuthToken(
            userId,
            role.getKey(),
            new Date(now.getTime() + appProperties.getAuth().getTokenExpiry())
        );

        long validTime = authRefreshToken.getTokenClaims().getExpiration().getTime() - now.getTime();

        // refresh Token이 3일 이하 남은 경우 -> 갱신
        if (validTime <= THREE_DAYS_MSEC) {
            long refreshTokenExpiry = appProperties.getAuth().getRefreshTokenExpiry();

            authRefreshToken = tokenProvider.createAuthToken(
                userId,
                role.getKey(),
                new Date(now.getTime() + refreshTokenExpiry)
            );

            // refresh Token - DB 업데이트
            memberRefreshToken.setRefreshToken(authRefreshToken.getToken());
            memberRefreshTokenRepository.save(memberRefreshToken); // JPA를 사용해 저장

            // refresh Token을 쿠키에 추가
            int cookieMaxAge = (int) refreshTokenExpiry / 60;
            CookieUtils.deleteCookie(request, response, REFRESH_TOKEN);
            CookieUtils.addCookie(response, REFRESH_TOKEN, authRefreshToken.getToken(), cookieMaxAge);
        }

        return ApiResponse.success("token", newAccessToken.getToken());
    }
}
