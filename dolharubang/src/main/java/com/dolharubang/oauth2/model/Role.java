package com.dolharubang.oauth2.model;

import java.util.Arrays;
import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum Role {

    USER("ROLE_USER", "회원"),
    ADMIN("ROLE_ADMIN", "관리자");

    private final String key;
    private final String title;

    public static Role of(String key) {
        return Arrays.stream(Role.values())
            .filter(r -> r.getKey().equals(key))
            .findAny()
            .orElse(null);
    }
}
