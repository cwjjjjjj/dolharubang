package com.dolharubang.oauth2.handler;

import static com.dolharubang.oauth2.repository.CookieAuthorizationRequestRepository.REDIRECT_URI_PARAM_COOKIE_NAME;
import jakarta.servlet.http.Cookie;

import com.dolharubang.oauth2.repository.CookieAuthorizationRequestRepository;
import com.dolharubang.oauth2.util.CookieUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationFailureHandler;
import org.springframework.stereotype.Component;
import org.springframework.web.util.UriComponentsBuilder;

/**
 * successHandler와 마찬가지로 최초 oauth 인증 요청 시, auth_code와 콜백 url로 리다이렉션 cookie에 저장된 redirect_uri를 가져옵니다.
 * 그리고 인증에 대한 오류를 error라는 parameter로 url에 함께 붙여 보내게 됩니다.
 */
@Component
@RequiredArgsConstructor
public class OAuth2AuthenticationFailureHandler extends SimpleUrlAuthenticationFailureHandler {

    private final CookieAuthorizationRequestRepository cookieAuthorizationRequestRepository;

    @Override
    public void onAuthenticationFailure(HttpServletRequest request, HttpServletResponse response,
        AuthenticationException exception) throws IOException, ServletException {
        // 쿠키에 저장된 redirect_url 가져오기
        String targetUrl = CookieUtils.getCookie(request, REDIRECT_URI_PARAM_COOKIE_NAME)
            .map(Cookie::getValue)
            .orElse("/");

        // query param 추가 후, uri 문자열로 변환
        targetUrl = UriComponentsBuilder.fromUriString(targetUrl)
            .queryParam("error", exception.getLocalizedMessage())
            .build().toUriString();

        cookieAuthorizationRequestRepository.removeAuthorizationRequestCookies(request, response);

        // redirect
        getRedirectStrategy().sendRedirect(request, response, targetUrl);
    }
}