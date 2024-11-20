package com.dolharubang.jwt;

import static com.dolharubang.jwt.JwtValidationType.VALID_JWT;
import static io.jsonwebtoken.lang.Strings.hasText;
import static org.springframework.http.HttpHeaders.AUTHORIZATION;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import lombok.val;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

@Slf4j
@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private static final String BEARER_HEADER = "Bearer ";
    private static final String BLANK = "";

    private final JwtTokenProvider jwtTokenProvider;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
        try {
            val token = getAccessTokenFromRequest(request);
            //토큰이 null이 아니고 유효하다면
            if (hasText(token) && jwtTokenProvider.validateToken(token) == VALID_JWT) {
                //jwt을 분석하여 사용자의 식별자를 추출한 후, 이를 기반으로 한 UserAuthentication 객체를 생성
                val authentication = new UserAuthentication(getMemberId(token), null, null);
                authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                //이 객체를 현재 보안 컨텍스트에 설정하여 애플리케이션 내의 다른 부분에서 현재 인증된 사용자에 대한 정보를 사용할 수 있도록 함
                SecurityContextHolder.getContext().setAuthentication(authentication);
            }
        } catch (Exception exception) {
            log.error(exception.getMessage());
        }

        filterChain.doFilter(request, response);
    }

    //요청에서 액세스 토큰을 추출
    //요청에 담긴 request에서 "authorization" 헤더를 추출하고 앞이 "Bearer"로 시작한다면 "Bearer"를 제거한 나머지 문자열을 토큰으로 가져옴
    private String getAccessTokenFromRequest(HttpServletRequest request) {
        return isContainsAccessToken(request) ? getAuthorizationAccessToken(request) : null;
    }

    private boolean isContainsAccessToken(HttpServletRequest request) {
        String authorization = request.getHeader(AUTHORIZATION);
        return authorization != null && authorization.startsWith(BEARER_HEADER);
    }

    private String getAuthorizationAccessToken(HttpServletRequest request) {
        return request.getHeader(AUTHORIZATION).replaceFirst(BEARER_HEADER, BLANK);
    }

    private long getMemberId(String token) {
        return jwtTokenProvider.getUserFromJwt(token);
    }
}
