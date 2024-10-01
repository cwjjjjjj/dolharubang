package com.dolharubang.oauth2.filter;

import com.dolharubang.oauth2.util.HeaderUtils;
import com.dolharubang.oauth2.token.AuthToken;
import com.dolharubang.oauth2.token.AuthTokenProvider;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;

@Slf4j
@RequiredArgsConstructor
public class TokenAuthenticationFilter extends OncePerRequestFilter {

    private final AuthTokenProvider tokenProvider;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
        FilterChain filterChain) throws ServletException, IOException {

        String accessToken = HeaderUtils.getAccessToken(request);
        AuthToken authToken = tokenProvider.convertAuthToken(accessToken);

        if (authToken.validate()) {
            Authentication authentication = tokenProvider.getAuthentication(authToken);// 인증된 사용자
            SecurityContextHolder.getContext().setAuthentication(authentication);
            log.debug(authentication.getName() + "의 인증정보 저장.");
        } else {
            log.debug("not exists invalid jwt token.");
        }

        filterChain.doFilter(request, response);
    }
}