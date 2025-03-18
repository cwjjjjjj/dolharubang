package com.dolharubang.domain.entity.oauth;

import java.util.Map;
import java.util.Optional;

public class AppleUserInfo implements OAuth2UserInfo {
    private Map<String, Object> attributes;

    public AppleUserInfo(Map<String, Object> attributes) {
        if (attributes == null || attributes.isEmpty()) {
            throw new IllegalArgumentException("Apple user attributes cannot be null or empty");
        }
        this.attributes = attributes;
    }

    @Override
    public String getProviderId() {
        // Apple의 'sub' 클레임 안전하게 추출
        return Optional.ofNullable(attributes.get("sub"))
            .map(Object::toString)
            .orElseThrow(() -> new IllegalStateException("Apple OAuth2 User ID (sub) is missing"));
    }

    @Override
    public String getProvider() {
        return "apple";
    }

    @Override
    public Map<String, Object> getAttributes() {
        return attributes;
    }

    public Optional<String> getEmail() {
        return Optional.ofNullable(attributes.get("email"))
            .map(Object::toString);
    }

    // 추가 검증 메서드
    public boolean isValidUser() {
        return attributes.containsKey("sub") &&
            attributes.get("sub") != null &&
            !attributes.get("sub").toString().trim().isEmpty();
    }
}
