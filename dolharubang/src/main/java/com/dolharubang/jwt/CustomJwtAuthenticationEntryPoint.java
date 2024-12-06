package com.dolharubang.jwt;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.InsufficientAuthenticationException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class CustomJwtAuthenticationEntryPoint implements AuthenticationEntryPoint {
    private final ObjectMapper objectMapper;

    @Override
    public void commence(HttpServletRequest request, HttpServletResponse response, AuthenticationException authException) throws IOException {
        int statusCode = determineStatusCode(authException);  // 예외 타입에 따라 상태 코드 결정
        setResponse(response, statusCode);
    }

    private int determineStatusCode(AuthenticationException authException) {
        // 예외 타입에 따라 적절한 상태 코드 반환
        if (authException instanceof BadCredentialsException) {
            return HttpServletResponse.SC_UNAUTHORIZED;
        } else if (authException instanceof InsufficientAuthenticationException) {
            return HttpServletResponse.SC_FORBIDDEN;
        }
        // 기본값
        return HttpServletResponse.SC_UNAUTHORIZED;
    }

    private void setResponse(HttpServletResponse response, int statusCode) throws IOException {
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/plain");
        response.setStatus(statusCode);
        response.getWriter().println(objectMapper.writeValueAsString("유효하지 않은 토큰입니다."));
    }
}
