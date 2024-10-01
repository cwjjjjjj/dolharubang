package com.dolharubang.oauth2.info;

import java.util.Map;

public class KakaoOAuth2UserInfo extends OAuth2UserInfo {

    public KakaoOAuth2UserInfo(Map<String, Object> attributes) {
        super(attributes);
    }

    @Override
    public String getId() {
        return attributes.get("id").toString();
    }

    @Override
    public String getEmail() {
        //return (String) attributes.get("email");
        return (String) ((Map<String, Object>) attributes.get("kakao_account")).get("email");
    }
}