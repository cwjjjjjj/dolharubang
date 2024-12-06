package com.dolharubang.domain.dto.response;

import com.dolharubang.jwt.Token;
import lombok.Builder;
import lombok.NonNull;

@Builder
public record SignInResDto(
    @NonNull String accessToken,
    @NonNull String refreshToken
) {

    public static SignInResDto of(Token token) {
        return SignInResDto.builder()
            .accessToken(token.getAccessToken())
            .refreshToken(token.getRefreshToken())
            .build();
    }
}