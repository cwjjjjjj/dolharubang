//package com.dolharubang.config;
//
//import com.dolharubang.jwt.CustomJwtAuthenticationEntryPoint;
//import com.dolharubang.jwt.JwtAuthenticationFilter;
//import lombok.RequiredArgsConstructor;
//import org.springframework.context.annotation.Bean;
//import org.springframework.context.annotation.Configuration;
//import org.springframework.security.config.annotation.web.builders.HttpSecurity;
//import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
//import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
//import org.springframework.security.config.http.SessionCreationPolicy;
//import org.springframework.security.web.SecurityFilterChain;
//import org.springframework.security.web.util.matcher.AntPathRequestMatcher;
//
//@Configuration
//@EnableWebSecurity
//@RequiredArgsConstructor
//public class SecurityConfig {
//
//    private final JwtAuthenticationFilter jwtAuthenticationFilter;
//    private final CustomJwtAuthenticationEntryPoint customJwtAuthenticationEntryPoint;
//
//    @Bean
//    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
//        return http
//            //csrf 보호 비활성화
//            .csrf(AbstractHttpConfigurer::disable)
//            .formLogin(AbstractHttpConfigurer::disable)
//            //세션 기반 인증을 사용하지 않음
//            .sessionManagement(sessionManagement ->
//                sessionManagement.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
//            )
//            //인증 실패 시 customJwtAuthenticationEntryPoint에서 처리
//            .exceptionHandling(exceptionHandling ->
//                exceptionHandling.authenticationEntryPoint(customJwtAuthenticationEntryPoint))
//            //설정한 url은 인증 없이 접근 가능
//            .authorizeHttpRequests(authorizeHttpRequests ->
//                authorizeHttpRequests
//                    .requestMatchers(new AntPathRequestMatcher("/api/v1/oauth2/**")).permitAll()
//                    .requestMatchers(new AntPathRequestMatcher("/error")).permitAll()
//                    .requestMatchers("/api/v1/login/page").permitAll()
//                    .anyRequest().authenticated())
//            //Http 요청이 UsernamePasswordAuthenticationFilter 전에 JwtAuthenticationFilter 거치게 함 TODO 주석 해제
////            .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class)
//            .build();
//    }
//}
