package com.dolharubang.domain.dto.oauth;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@JsonPropertyOrder({"accessToken", "refreshToken"})
@Builder
public class OAuth2LoginResDto {
    private String accessToken;
    private String refreshToken;

    @JsonProperty("accessToken")
    public String getAccessToken(){
        return accessToken;
    }
    @JsonProperty("refreshToken")
    public String getRefreshToken(){
        return refreshToken;
    }
}
