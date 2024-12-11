package com.dolharubang.domain.dto.request;

import com.dolharubang.type.SocialType;
import lombok.NonNull;

public record SignInReqDto(
    @NonNull
    SocialType socialType
) {

    public static SignInReqDto of(SocialType socialType) {
        return new SignInReqDto(socialType);
    }
}
