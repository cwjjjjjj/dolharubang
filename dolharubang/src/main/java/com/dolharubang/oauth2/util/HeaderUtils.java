package com.dolharubang.oauth2.util;

import jakarta.servlet.http.HttpServletRequest;

//Front에서 보내는 Header 값에서 Access Token을 다룬다
public class HeaderUtils {

    private final static String HEADER_AUTHORIZATION = "Authorization";
    private final static String TOKEN_PREFIX = "Bearer ";

    public static String getAccessToken(HttpServletRequest request) {
        String headerValue = request.getHeader(HEADER_AUTHORIZATION);//authorization 값 return

        if(headerValue == null) {
            return null;
        }

        if(headerValue.startsWith(TOKEN_PREFIX)) {
            return headerValue.substring(TOKEN_PREFIX.length());//token 값 반환
        }

        return null;
    }

}