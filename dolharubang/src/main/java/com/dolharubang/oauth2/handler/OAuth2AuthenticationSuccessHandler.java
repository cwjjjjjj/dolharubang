package com.dolharubang.oauth2.handler;

import static com.dolharubang.oauth2.repository.CookieAuthorizationRequestRepository.REDIRECT_URI_PARAM_COOKIE_NAME;
import static org.springframework.security.oauth2.core.endpoint.OAuth2ParameterNames.REFRESH_TOKEN;
import jakarta.servlet.http.Cookie;
import com.dolharubang.oauth2.info.OAuth2UserInfo;
import com.dolharubang.oauth2.info.OAuth2UserInfoFactory;
import com.dolharubang.oauth2.model.Role;
import com.dolharubang.config.properties.AppProperties;
import com.dolharubang.oauth2.repository.CookieAuthorizationRequestRepository;
import com.dolharubang.oauth2.token.AuthToken;
import com.dolharubang.oauth2.token.AuthTokenProvider;
import com.dolharubang.oauth2.util.CookieUtils;
import com.dolharubang.repository.MemberRefreshTokenRepository;
import jakarta.servlet.http.HttpServletRequest;
import java.net.URI;
import java.util.Collection;
import java.util.Date;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.oauth2.client.authentication.OAuth2AuthenticationToken;
import org.springframework.security.oauth2.core.oidc.user.OidcUser;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationSuccessHandler;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import org.springframework.stereotype.Component;
import org.springframework.web.util.UriComponentsBuilder;
import com.dolharubang.domain.entity.MemberRefreshToken;

@Slf4j
@Component
@RequiredArgsConstructor
public class OAuth2AuthenticationSuccessHandler extends SimpleUrlAuthenticationSuccessHandler {

    private final AuthTokenProvider tokenProvider;
    private final AppProperties appProperties;
    private final MemberRefreshTokenRepository memberRefreshTokenRepository;
    private final CookieAuthorizationRequestRepository cookieAuthorizationRequestRepository;

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response, Authentication authentication) throws IOException, ServletException {
        String targetUrl = determineTargetUrl(request, response, authentication);

        if(response.isCommitted()) {
            log.debug("Response has already been committed.");
            return;
        }

        clearAuthenticationAttributes(request, response);
        getRedirectStrategy().sendRedirect(request, response, targetUrl);
    }

    protected String determineTargetUrl(HttpServletRequest request, HttpServletResponse response, Authentication authentication) {
        Optional<String> redirectUri = CookieUtils.getCookie(request, REDIRECT_URI_PARAM_COOKIE_NAME)
            .map(Cookie::getValue);

        //cookie uri가 존재 + 허용된 도메인인가 : (미리 설정한 redirect url과 같은지 확인 작업)
        if(redirectUri.isPresent() && !isAuthorizedRedirectUri(redirectUri.get())) {
            throw new IllegalArgumentException("Sorry! We've got an Unauthorized Redirect URI and can't proceed with the authentication");
        }

        // 사용자가 인증에 실패하면 /login 페이지로 리디렉션, error라는 쿼리 파라미터가 추가
        String targetUrl = redirectUri.orElse(getDefaultTargetUrl());

        OAuth2AuthenticationToken authToken = (OAuth2AuthenticationToken) authentication;//인증에 사용된 oauth2 토큰

        OidcUser user = (OidcUser) authentication.getPrincipal();//사용자 정보
        OAuth2UserInfo userInfo = OAuth2UserInfoFactory.getOAuth2UserInfo(user.getAttributes());
        Collection<? extends GrantedAuthority> authorities = ((OidcUser) authentication.getPrincipal()).getAuthorities();//권한

        Role roleType = hasAuthority(authorities, Role.ADMIN.getKey()) ? Role.ADMIN : Role.USER;

        Date now = new Date();

        // Access Token 생성
        AuthToken accessToken = tokenProvider.createAuthToken(
            userInfo.getId(),
            roleType.getKey(),
            new Date(now.getTime() + appProperties.getAuth().getTokenExpiry())
        );

        // Refresh Token 생성
        long refreshTokenExpiry = appProperties.getAuth().getRefreshTokenExpiry();

        AuthToken refreshToken = tokenProvider.createAuthToken(
            appProperties.getAuth().getTokenSecret(),
            new Date(now.getTime() + refreshTokenExpiry)
        );

        // DB save
        MemberRefreshToken memberRefreshToken = memberRefreshTokenRepository.();

        if(memberRefreshToken != null) {
            memberRefreshToken.setRefreshToken(refreshToken.getToken());
        } else {
            memberRefreshToken = MemberRefreshToken.builder()
                .userId(userInfo.getId())
                .refreshToken(refreshToken.getToken())
                .build();
            memberRefreshTokenRepository.saveAndFlush(memberRefreshToken);
        }

        int cookieMaxAge = (int) (refreshTokenExpiry / 60);

        // Access Token : LocalStorage / Refresh Token : Cookie(http only secure)에 저장
        CookieUtils.deleteCookie(request, response, REFRESH_TOKEN);
        CookieUtils.addCookie(response, REFRESH_TOKEN, refreshToken.getToken(), cookieMaxAge);

        return UriComponentsBuilder.fromUriString(targetUrl)
            .queryParam("token", accessToken.getToken())
            .build().toUriString();
    }

    protected void clearAuthenticationAttributes(HttpServletRequest request, HttpServletResponse response) {
        super.clearAuthenticationAttributes(request);
        cookieAuthorizationRequestRepository.removeAuthorizationRequestCookies(request, response);
    }

    private boolean hasAuthority(Collection<? extends GrantedAuthority> authorities, String authority) {
        if (authorities == null) {
            return false;
        }

        for (GrantedAuthority grantedAuthority : authorities) {
            if (authority.equals(grantedAuthority.getAuthority())) {
                return true;
            }
        }
        return false;
    }

    private boolean isAuthorizedRedirectUri(String uri) {
        URI clientRedirectUri = URI.create(uri);

        return appProperties.getOAuth2().getAuthorizedRedirectUris()
            .stream()
            .anyMatch(authorizedRedirectUri -> {
                //validate host and port
                URI authorizedUri = URI.create(authorizedRedirectUri);
                if(authorizedUri.getHost().equalsIgnoreCase(clientRedirectUri.getHost())// getHost() - 도메인 부분 추출
                    && authorizedUri.getPort() == clientRedirectUri.getPort()) {
                    return true;
                }
                return false;
            });
    }

}