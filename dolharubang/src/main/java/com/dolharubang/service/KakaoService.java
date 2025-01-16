package com.dolharubang.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.gson.JsonArray;
import java.util.HashMap;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.json.MappingJackson2HttpMessageConverter;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
@RequiredArgsConstructor
public class KakaoService {

    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;

    /*
    닉네임	profile_nickname	선택 동의설정
    프로필 사진	profile_image	선택 동의설정
    카카오계정(이메일)	account_email	필수 동의
     */
    public String getKakaoData(String socialAccessToken) {
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.add("Authorization", socialAccessToken);
            HttpEntity httpEntity = new HttpEntity<JsonArray>(headers);
            // 응답 데이터(json)를 Map 으로 받을 수 있도록 메시지 컨버터 추가
            restTemplate.getMessageConverters().add(new MappingJackson2HttpMessageConverter());

            // Post 방식으로 Http 요청
            // 응답 데이터 형식은 Hashmap 으로 지정
            ResponseEntity<HashMap> result = restTemplate.postForEntity(tokenURL, entity, HashMap.class);
            Map<String, String> resMap = result.getBody();

            // 응답 데이터 확인
            System.out.println(resMap);
        } catch (Exception exception) {
            throw new IllegalStateException();
        }
    }
}
