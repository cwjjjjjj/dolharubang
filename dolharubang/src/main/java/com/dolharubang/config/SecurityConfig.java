package com.dolharubang.config;

import com.dolharubang.config.oauth.JwtSecurityConfig;
import com.dolharubang.jwt.JwtAccessDeniedHandler;
import com.dolharubang.jwt.JwtAuthenticationEntryPoint;
import com.dolharubang.jwt.TokenProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
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

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
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
                    "/api-docs/**", "/v3/api-docs/**", "/api/v1/auth/**", "/api/v1/**").permitAll()
                .anyRequest().authenticated())
            .exceptionHandling((auth) ->
                auth.authenticationEntryPoint(jwtAuthenticationEntryPoint)
                    .accessDeniedHandler(jwtAccessDeniedHandler))
            .with(new JwtSecurityConfig(tokenProvider), c -> c.getClass())
            .sessionManagement(sm -> sm.sessionCreationPolicy(SessionCreationPolicy.STATELESS));

        return http.build();
    }

    @Bean
    public CorsConfigurationSource configurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.addAllowedOriginPattern("*");
        configuration.addAllowedHeader("*");
        configuration.addAllowedMethod("*");
        configuration.setAllowCredentials(true);
        configuration.addExposedHeader("Authorization");
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}
