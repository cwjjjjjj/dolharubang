package com.dolharubang.config;

import com.dolharubang.config.oauth.AppleProperties;
import com.dolharubang.config.oauth.CustomRequestEntityConverter;
import com.dolharubang.config.oauth.JwtSecurityConfig;
import com.dolharubang.domain.dto.oauth.ApiResponse;
import com.dolharubang.domain.dto.oauth.OAuth2LoginResDto;
import com.dolharubang.domain.dto.oauth.SuccessStatus;
import com.dolharubang.domain.dto.oauth.TokenDto;
import com.dolharubang.domain.entity.oauth.PrincipalDetails;
import com.dolharubang.jwt.JwtAccessDeniedHandler;
import com.dolharubang.jwt.JwtAuthenticationEntryPoint;
import com.dolharubang.jwt.TokenProvider;
import com.dolharubang.repository.RefreshTokenRepository;
import com.dolharubang.service.oauth.PrincipalOauth2UserService;
import com.dolharubang.service.oauth.RefreshTokenService;
import com.dolharubang.type.Authority;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.PrintWriter;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpStatus;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.client.endpoint.DefaultAuthorizationCodeTokenResponseClient;
import org.springframework.security.oauth2.client.endpoint.OAuth2AccessTokenResponseClient;
import org.springframework.security.oauth2.client.endpoint.OAuth2AuthorizationCodeGrantRequest;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

@Configuration
@RequiredArgsConstructor
@EnableMethodSecurity
public class SecurityConfig {

    private final TokenProvider tokenProvider;
    private final JwtAuthenticationEntryPoint jwtAuthenticationEntryPoint;
    private final JwtAccessDeniedHandler jwtAccessDeniedHandler;
    private final PrincipalOauth2UserService principalOauth2UserService;
    private final RefreshTokenRepository refreshTokenRepository;
    private final RefreshTokenService refreshTokenService;
    private final AppleProperties appleProperties;

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public OAuth2AccessTokenResponseClient<OAuth2AuthorizationCodeGrantRequest> accessTokenResponseClient(
        CustomRequestEntityConverter customRequestEntityConverter) {
        DefaultAuthorizationCodeTokenResponseClient accessTokenResponseClient = new DefaultAuthorizationCodeTokenResponseClient();
        accessTokenResponseClient.setRequestEntityConverter(customRequestEntityConverter);

        return accessTokenResponseClient;
    }

    @Bean
    public CustomRequestEntityConverter customRequestEntityConverter() {
        return new CustomRequestEntityConverter(appleProperties);
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {

        http
            .csrf((auth) -> auth.disable())
            .headers(h -> h.frameOptions(f -> f.sameOrigin()))
            .cors((co) -> co.configurationSource(configurationSource()))
            .formLogin((auth) -> auth.disable())
            .httpBasic((auth) -> auth.disable())
            .authorizeHttpRequests((auth) -> auth
                .requestMatchers("/swagger", "/swagger-ui.html", "/swagger-ui/**", "/api-docs",
                    "/api-docs/**", "/v3/api-docs/**").permitAll()
                .requestMatchers("/api/auth/**").permitAll()
                .requestMatchers("/login/oauth2/code/**", "/api/v1/login/oauth2/code/**")
                .permitAll() // 이 줄 추가
                .requestMatchers("/test.html").permitAll()
                .anyRequest().authenticated())
            .oauth2Login(oauth2Login -> oauth2Login
                .tokenEndpoint(tokenEndpointConfig -> tokenEndpointConfig.accessTokenResponseClient(
                    accessTokenResponseClient(customRequestEntityConverter())))
                .userInfoEndpoint(userInfoEndpointConfig -> userInfoEndpointConfig.userService(
                    principalOauth2UserService))
                .successHandler(successHandler()))
            .exceptionHandling((auth) ->
                auth.authenticationEntryPoint(jwtAuthenticationEntryPoint)
                    .accessDeniedHandler(jwtAccessDeniedHandler))
            .with(new JwtSecurityConfig(tokenProvider), c -> c.getClass())
            .sessionManagement(sm -> sm.sessionCreationPolicy(SessionCreationPolicy.STATELESS));

        return http.build();
    }

    @Bean
    public AuthenticationSuccessHandler successHandler() {
        return (request, response, authentication) -> {
            // PrincipalDetails로 캐스팅하여 인증된 사용자 정보를 가져온다.
            PrincipalDetails principal = (PrincipalDetails) authentication.getPrincipal();

            boolean isGuest = false;
            if (principal.getMember().getAuthority().equals(Authority.ROLE_GUEST)) {
                isGuest = true;
            }
            // jwt token 발행을 시작한다.
            TokenDto tokenDto = tokenProvider.generateTokenDto(authentication);

            refreshTokenService.saveOrUpdateRefreshToken(
                principal.getMember().getMemberId(),
                tokenDto.getRefreshToken()
            );

            OAuth2LoginResDto oAuth2LoginResDto = OAuth2LoginResDto.builder()
                .accessToken(tokenDto.getAccessToken())
                .refreshToken(tokenDto.getRefreshToken())
                .isGuest(isGuest)
                .build();

            ObjectMapper objectMapper = new ObjectMapper();
            ApiResponse<OAuth2LoginResDto> apiResponse = ApiResponse.onSuccess(SuccessStatus._OK,
                oAuth2LoginResDto);
            // JSON 직렬화
            String jsonResponse = objectMapper.writeValueAsString(apiResponse);

            // 응답 설정
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.setStatus(HttpStatus.UNAUTHORIZED.value());

            // 응답 전송
            PrintWriter out = response.getWriter();
            out.println(jsonResponse);
            out.flush();
        };
    }

    @Bean
    public CorsConfigurationSource configurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.addAllowedOriginPattern("*"); // 모든 IP 주소 허용
        configuration.addAllowedHeader("*");
        configuration.addAllowedMethod("*"); // GET, POST, PUT, DELETE (Javascript 요청 허용)
        configuration.setAllowCredentials(true); // 클라이언트에서 쿠키 요청 허용
        configuration.addExposedHeader("Authorization");
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}
