package com.dolharubang.service.oauth;

import com.dolharubang.domain.dto.oauth.KakaoDTO;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Slf4j
@Service
@RequiredArgsConstructor
public class KakaoService {

    private final RestTemplate restTemplate;

    /**
     * 카카오 액세스 토큰을 사용하여 사용자 정보를 가져옵니다.
     * 이 메서드는 iOS 앱에서 전달받은 액세스 토큰을 이용합니다.
     *
     * @param accessToken 카카오 액세스 토큰
     * @return 사용자 정보를 담은 KakaoDTO 객체
     */
    public KakaoDTO getUserInfoWithToken(String accessToken) {
        // HTTP 헤더 설정
        HttpHeaders headers = new HttpHeaders();
        headers.add("Authorization", "Bearer " + accessToken);
        headers.add("Content-type", "application/json");

        // HTTP 요청 엔티티 생성
        HttpEntity<String> entity = new HttpEntity<>(headers);

        // 카카오 API 호출하여 사용자 정보 가져오기
        ResponseEntity<Map> response = restTemplate.exchange(
            "https://kapi.kakao.com/v2/user/me",
            HttpMethod.GET,
            entity,
            Map.class
        );

        // 응답 본문 추출
        Map<String, Object> responseBody = response.getBody();

        // 필요한 사용자 정보 추출
        Long id = Long.valueOf(responseBody.get("id").toString());

        // 카카오 계정 정보 추출
        Map<String, Object> kakaoAccount = (Map<String, Object>) responseBody.get("kakao_account");
        String email = kakaoAccount != null && kakaoAccount.containsKey("email") ?
            (String) kakaoAccount.get("email") : null;

        // 프로필 정보 추출
        Map<String, Object> properties = (Map<String, Object>) responseBody.get("properties");

        String nickname = properties != null && properties.containsKey("nickname") ?
            (String) properties.get("nickname") : "사용자" + id;

        String profileImageUrl = properties != null && properties.containsKey("profile_image") ?
            (String) properties.get("profile_image") : null;

        // DTO 객체 생성 및 반환
        return KakaoDTO.builder()
            .id(id)
            .email(email)
            .nickname(nickname)
            .profileImageUrl(profileImageUrl)
            .build();
    }

    /**
     * 카카오 액세스 토큰의 유효성을 검증합니다.
     *
     * @param accessToken 카카오 액세스 토큰
     * @return 토큰이 유효하면 true, 그렇지 않으면 false
     */
    public boolean validateAccessToken(String accessToken) {
        try {
            // HTTP 헤더 설정
            HttpHeaders headers = new HttpHeaders();
            headers.add("Authorization", "Bearer " + accessToken);
            HttpEntity<String> entity = new HttpEntity<>(headers);

            // 카카오 토큰 정보 API 호출
            ResponseEntity<Map> response = restTemplate.exchange(
                "https://kapi.kakao.com/v1/user/access_token_info",
                HttpMethod.GET,
                entity,
                Map.class
            );

            // 응답 코드가 200이면 유효한 토큰
            return response.getStatusCode().is2xxSuccessful();
        } catch (Exception e) {
            log.error("카카오 액세스 토큰 검증 실패: {}", e.getMessage());
            return false;
        }
    }
}