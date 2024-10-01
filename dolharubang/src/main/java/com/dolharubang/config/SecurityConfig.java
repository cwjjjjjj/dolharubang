package com.dolharubang.config;

import com.dolharubang.oauth2.exception.RestAuthenticationEntryPoint;
import com.dolharubang.oauth2.filter.TokenAuthenticationFilter;
import com.dolharubang.oauth2.handler.OAuth2AuthenticationFailureHandler;
import com.dolharubang.oauth2.handler.OAuth2AuthenticationSuccessHandler;
import com.dolharubang.oauth2.handler.TokenAccessDeniedHandler;
import com.dolharubang.oauth2.repository.CookieAuthorizationRequestRepository;
import com.dolharubang.oauth2.service.CustomOAuth2UserService;
import com.dolharubang.oauth2.service.CustomMemberDetailsService;
import com.dolharubang.oauth2.token.AuthTokenProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.security.web.csrf.CookieCsrfTokenRepository;
import org.springframework.web.cors.CorsConfiguration;

@Configuration
@RequiredArgsConstructor
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true)
public class SecurityConfig {

    private final CustomMemberDetailsService userDetailsService;
    private final CustomOAuth2UserService oAuth2UserService;
    private final AuthTokenProvider tokenProvider;
    private final CookieAuthorizationRequestRepository cookieAuthorizationRequestRepository;
    private final OAuth2AuthenticationFailureHandler oAuth2AuthenticationFailureHandler;
    private final OAuth2AuthenticationSuccessHandler oAuth2AuthenticationSuccessHandler;
    private final TokenAccessDeniedHandler tokenAccessDeniedHandler;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {

        // httpBasic, csrf, formLogin, rememberMe, session disable
        http
            .cors(cors -> cors.configurationSource(request -> new CorsConfiguration().applyPermitDefaultValues())) // CORS 설정
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS)) // 세션 비활성화
            .csrf(csrf -> csrf
                .csrfTokenRepository(CookieCsrfTokenRepository.withHttpOnlyFalse())) // CSRF 비활성화
            .formLogin(form -> form.disable()) // formLogin 비활성화
            .httpBasic(basic -> basic.disable()) // httpBasic 비활성화
            .rememberMe(remember -> remember.disable()) // rememberMe 비활성화
            .exceptionHandling(exceptions -> exceptions
                .authenticationEntryPoint(new RestAuthenticationEntryPoint()) // 401 처리
                .accessDeniedHandler(tokenAccessDeniedHandler) // 403 처리
            );

        // 요청 권한 설정
        http.authorizeHttpRequests(authz -> authz
            .requestMatchers("/oauth2/**").permitAll() // OAuth2 관련 요청 모두 허용
            .anyRequest().authenticated() // 그 외 모든 요청 인증 필요
        );

        // OAuth2 로그인 설정
        http.oauth2Login(oauth2 -> oauth2
            .authorizationEndpoint(authorization -> authorization
                .baseUri("/oauth2/authorization") // 인증 요청 URL 설정
                .authorizationRequestRepository(cookieAuthorizationRequestRepository) // 인증 요청을 cookie에 저장
            )
            .redirectionEndpoint(redirection -> redirection
                .baseUri("/*/oauth2/code/*") // 인증 후 리디렉션 URL
            )
            .userInfoEndpoint(userInfo -> userInfo
                .userService(oAuth2UserService) // 사용자 정보 처리 서비스 지정
            )
            .successHandler(oAuth2AuthenticationSuccessHandler) // 인증 성공 핸들러
            .failureHandler(oAuth2AuthenticationFailureHandler) // 인증 실패 핸들러
        );

        // 로그아웃 설정
        http.logout(logout -> logout
            .clearAuthentication(true)
            .deleteCookies("JSESSIONID")
        );

        // JWT 필터 설정
        http.addFilterBefore(new TokenAuthenticationFilter(tokenProvider), UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}
