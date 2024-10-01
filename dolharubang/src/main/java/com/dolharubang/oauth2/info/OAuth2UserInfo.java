package com.dolharubang.oauth2.info;

import java.util.Map;
import lombok.Getter;

@Getter
public abstract class OAuth2UserInfo {

    protected Map<String, Object> attributes;

    public OAuth2UserInfo(Map<String, Object> attributes) {
        this.attributes = attributes;
    }

    public abstract String getId(); //소셜 식별 값
    public abstract String getEmail();
}