package com.dolharubang.oauth2.exception;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;

/**
 * 사용자가 인증없이 요청시, 401 unauthorized 처리(인증)
 */
@Slf4j
public class RestAuthenticationEntryPoint implements AuthenticationEntryPoint {

    @Override
    public void commence(HttpServletRequest request, HttpServletResponse response,
        AuthenticationException authException) throws IOException, ServletException {
        log.info("Responding with unauthorized error. Message = {}", authException.getMessage());
        response.sendError(HttpServletResponse.SC_UNAUTHORIZED,
            authException.getLocalizedMessage());
    }
}