package com.dolharubang.domain.entity.oauth;

import java.util.Map;

public interface OAuth2UserInfo {
    String getProviderId();
    String getProvider();
    Map<String, Object> getAttributes();
}
