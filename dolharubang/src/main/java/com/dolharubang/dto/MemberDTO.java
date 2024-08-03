package com.dolharubang.dto;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class MemberDTO {

    private String memberEmail;
    private String nickname;
    private String birthday;
    private String refresh_token;
    private String provider;
    private String sands;
    private String created_at;
    private String last_login_at;
    private String total_login_days;
    private String profile_picture;

    public MemberDTO(String memberEmail, String nickname, String birthday, String refresh_token,
        String provider, String sands, String created_at, String last_login_at,
        String total_login_days,
        String profile_picture) {
        this.memberEmail = memberEmail;
        this.nickname = nickname;
        this.birthday = birthday;
        this.refresh_token = refresh_token;
        this.provider = provider;
        this.sands = sands;
        this.created_at = created_at;
        this.last_login_at = last_login_at;
        this.total_login_days = total_login_days;
        this.profile_picture = profile_picture;
    }
}
