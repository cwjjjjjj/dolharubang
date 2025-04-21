package com.dolharubang.domain.entity.oauth;

import java.util.Map;
import java.util.Optional;

public class KakaoUserInfo implements OAuth2UserInfo {

    private Map<String, Object> attributes;

    public KakaoUserInfo(Map<String, Object> attributes) {
        this.attributes = attributes;
    }

    @Override
    public String getProviderId() {
        return attributes.get("id").toString();
    }

    @Override
    public String getProvider() {
        return "kakao";
    }

    @Override
    public Map<String, Object> getAttributes() {
        return attributes;
    }

    public Optional<String> getEmail() {
        Map<String, Object> kakaoAccount = (Map<String, Object>) attributes.get("kakao_account");
        return Optional.ofNullable(kakaoAccount)
            .map(account -> (String) account.get("email"));
    }

    public Optional<String> getProfilePicture() {
        Map<String, Object> properties = (Map<String, Object>) attributes.get("properties");
        return Optional.ofNullable(properties)
            .map(props -> (String) props.get("profile_image"));
    }

    public Optional<String> getNickname() {
        Map<String, Object> properties = (Map<String, Object>) attributes.get("properties");
        return Optional.ofNullable(properties)
            .map(props -> (String) props.get("nickname"));
}
}
