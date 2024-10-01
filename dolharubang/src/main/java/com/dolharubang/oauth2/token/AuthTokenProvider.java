package com.dolharubang.oauth2.token;

import com.dolharubang.domain.entity.Member;
import com.dolharubang.oauth2.exception.TokenValidFailedException;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.security.Keys;
import java.security.Key;
import java.util.Arrays;
import java.util.Collection;
import java.util.Date;
import java.util.stream.Collectors;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;

@Slf4j
public class AuthTokenProvider {

    private final Key key;
    private static final String AUTHORITIES_KEY = "role";

    public AuthTokenProvider(String secret) {
        this.key = Keys.hmacShaKeyFor(secret.getBytes());
    }

    public AuthToken createAuthToken(String id, Date expiry) {
        return new AuthToken(id, expiry, key);
    }

    public AuthToken createAuthToken(String id, String role, Date expiry) {
        return new AuthToken(id, role, expiry, key);
    }

    public AuthToken convertAuthToken(String token) {
        return new AuthToken(key, token);
    }

    public Authentication getAuthentication(AuthToken authToken) {

        if (authToken.validate()) {// 유효하면 true
            Claims claims = authToken.getTokenClaims();// Claims - JWT JSON 정보
            Collection<? extends GrantedAuthority> authorities =
                Arrays.stream(new String[]{claims.get(AUTHORITIES_KEY).toString()})
                    .map(SimpleGrantedAuthority::new)
                    .collect(Collectors.toList());

            log.debug("claims subject := [{}]", claims.getSubject());
            Member principal = new Member(claims.getSubject(), "", authorities);// 권한 정보로 User 객체 생성

            return new UsernamePasswordAuthenticationToken(principal, authToken, authorities);//인증된 사용자
        } else {
            throw new TokenValidFailedException();
        }
    }

}