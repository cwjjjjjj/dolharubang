package com.dolharubang.oauth2.util;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.Serializable;
import java.util.Arrays;
import java.util.Base64;
import java.util.Optional;
import org.apache.commons.lang3.SerializationUtils;

public class CookieUtils {

    public static Optional<Cookie> getCookie(HttpServletRequest request, String name) {
        Cookie[] cookies = request.getCookies();

        if(cookies != null && cookies.length > 0) { //쿠키가 있으면
            for(Cookie cookie : cookies) {
                if(name.equals(cookie.getName())) {
                    return Optional.of(cookie);
                }
            }
        }
        return Optional.empty();
    }

    public static Optional<String> readServletCookie(HttpServletRequest request, String name) {
        return Arrays.stream(request.getCookies())
            .filter(cookie -> name.equals(cookie.getName()))
            .map(Cookie::getValue)
            .findAny();
    }

    public static void addCookie(HttpServletResponse response, String name, String value, int maxAge) {
        Cookie cookie = new Cookie(name, value);
        cookie.setPath("/");//cookie의 유효한 범위 - 모든 경로에서 유효
        cookie.setHttpOnly(true);
        cookie.setMaxAge(maxAge);

        response.addCookie(cookie);
    }

    public static void deleteCookie(HttpServletRequest request, HttpServletResponse response, String name) {
        Cookie[] cookies = request.getCookies();

        Arrays.stream(cookies)
            .filter(cookie -> name.equals(cookie.getName()))
            .forEach(cookie -> {
                cookie.setValue("");
                cookie.setPath("/");
                cookie.setMaxAge(0);
                response.addCookie(cookie);
            });
    }

    /**
     * 쿠키에 저장할 객체를 Base64로 인코딩
     * 크기가 작을수록 더 효율적으로 HTTP 헤더에 포함되어 전송가능
     */
    public static String serialize(Serializable object) {
        return Base64.getUrlEncoder()
            .encodeToString(SerializationUtils.serialize(object));
    }

    /**
     * 쿠키에 저장된 객체를 Base64로 디코딩
     * 크기가 작을수록 더 효율적으로 HTTP 헤더에 포함되어 전송가능
     */
    public static <T> T deserialize(Cookie cookie, Class<T> cls) {
        return cls.cast(
            SerializationUtils.deserialize(Base64.getUrlDecoder().decode(cookie.getValue()))//쿠키값을 Object.class 객체로 변환
        );
    }


}