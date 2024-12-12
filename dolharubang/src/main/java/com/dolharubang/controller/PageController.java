package com.dolharubang.controller;

import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
@RequestMapping("/api/v1/oauth2")
@Tag(name = "카카오 로그인 테스트", description = "백엔드 테스트를 위한 코드")
public class PageController {

    @Value("${spring.security.oauth2.client.registration.kakao.client-id}")
    private String clientId;

    @Value("${spring.security.oauth2.client.registration.kakao.redirect-uri}")
    private String redirectUri;

    //카카오 로그인 요청을 보낼 주소.
    @GetMapping("/login/page")
    public String loginPage(Model model) {
        model.addAttribute("kakaoApiKey", clientId);
        model.addAttribute("redirectUri", redirectUri);
        return "loginTestPage";
    }

    //정상 로그인 후 응답 돌아오는 redirect uri. 직접 접속 X.
    @GetMapping("/code/kakao")
    public @ResponseBody String kakaoCallback(String code) {

        return "카카오 인증 완료. 코드값:" + code;
    }
}
