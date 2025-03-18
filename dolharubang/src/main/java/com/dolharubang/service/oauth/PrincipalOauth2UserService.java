package com.dolharubang.service.oauth;

import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.oauth.AppleUserInfo;
import com.dolharubang.domain.entity.oauth.KakaoUserInfo;
import com.dolharubang.domain.entity.oauth.OAuth2UserInfo;
import com.dolharubang.domain.entity.oauth.PrincipalDetails;
import com.dolharubang.repository.MemberRepository;
import com.dolharubang.type.Authority;
import com.dolharubang.type.Provider;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;
@Service
@RequiredArgsConstructor
public class PrincipalOauth2UserService extends DefaultOAuth2UserService {

    private final MemberRepository memberRepository;

    @Override
    public OAuth2User loadUser(OAuth2UserRequest userRequest) throws OAuth2AuthenticationException {
        OAuth2UserInfo oAuth2UserInfo = null;
        OAuth2User oAuth2User;

        if (userRequest.getClientRegistration().getRegistrationId().equals("apple")) {
            String idToken = userRequest.getAdditionalParameters().get("id_token").toString();
            oAuth2UserInfo = new AppleUserInfo(decodeJwtTokenPayload(idToken));
        } else if (userRequest.getClientRegistration().getRegistrationId().equals("kakao")) {
            oAuth2User = super.loadUser(userRequest);
            oAuth2UserInfo = new KakaoUserInfo(oAuth2User.getAttributes());
        }

        String provider = oAuth2UserInfo.getProvider().toUpperCase();
        String providerId = oAuth2UserInfo.getProviderId();

        Member member = memberRepository.findByProviderAndProviderId(Provider.valueOf(provider),
            providerId);

        //회원가입 로직
        if (member == null) {
            String authority = "ROLE_GUEST";

            // 이메일 정보 추출
            String memberEmail = null;
            if (oAuth2UserInfo instanceof KakaoUserInfo) {
                memberEmail = String.valueOf(((KakaoUserInfo) oAuth2UserInfo).getEmail());
            }
            if (oAuth2UserInfo instanceof AppleUserInfo) {
                memberEmail = ((AppleUserInfo) oAuth2UserInfo).getEmail().orElse(null);
            }

            // 프로필 이미지 정보 추출
            String profilePicture = null;
            if (oAuth2UserInfo instanceof KakaoUserInfo) {
                profilePicture = ((KakaoUserInfo) oAuth2UserInfo).getProfilePicture().orElse(null);
            }
            if (profilePicture == null) {
                //TODO 기본 프로필 사진 설정
            }

            member = Member.builder()
                .authority(Authority.valueOf(authority))
                .provider(Provider.valueOf(provider))
                .providerId(providerId)
                .memberEmail(memberEmail)
                .nickname(null)
                .birthday(null)
                .sands(0)
                .profilePicture(profilePicture)
                .spaceName(null) // 기본값 설정
                .build();

            memberRepository.save(member);
            return new PrincipalDetails(member, oAuth2UserInfo.getAttributes());
        }
        return new PrincipalDetails(member, oAuth2UserInfo.getAttributes());
    }

    public Map<String, Object> decodeJwtTokenPayload(String jwtToken) {
        Map<String, Object> jwtClaims = new HashMap<>();
        try {
            String[] parts = jwtToken.split("\\.");
            Base64.Decoder decoder = Base64.getUrlDecoder();

            byte[] decodedBytes = decoder.decode(parts[1].getBytes(StandardCharsets.UTF_8));
            String decodedString = new String(decodedBytes, StandardCharsets.UTF_8);
            ObjectMapper mapper = new ObjectMapper();

            Map<String, Object> map = mapper.readValue(decodedString, Map.class);
            jwtClaims.putAll(map);

        } catch (JsonProcessingException e) {
//        logger.error("decodeJwtToken: {}-{} / jwtToken : {}", e.getMessage(), e.getCause(), jwtToken);
        }
        return jwtClaims;
    }
}
