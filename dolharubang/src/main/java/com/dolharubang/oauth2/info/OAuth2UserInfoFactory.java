package com.dolharubang.oauth2.info;

import java.util.Map;

public class OAuth2UserInfoFactory {

    public static OAuth2UserInfo getOAuth2UserInfo(Map<String, Object> attributes) {
        return new KakaoOAuth2UserInfo(attributes);
    }

}