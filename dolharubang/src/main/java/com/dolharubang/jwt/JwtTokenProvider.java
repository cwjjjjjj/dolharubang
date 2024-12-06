package com.dolharubang.jwt;

import static io.jsonwebtoken.Header.JWT_TYPE;
import static io.jsonwebtoken.Header.TYPE;
import static io.jsonwebtoken.security.Keys.hmacShaKeyFor;
import static java.util.Base64.getEncoder;

import com.dolharubang.config.ValueConfig;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.MalformedJwtException;
import io.jsonwebtoken.UnsupportedJwtException;
import java.util.Date;
import javax.crypto.SecretKey;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import lombok.val;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class JwtTokenProvider {

    //security와 jwt 토근을 사용해 인증과 권한 부여 처리하는 클래스
    //jwt 토근의 생성, 복호화, 검증

    private final ValueConfig valueConfig;

    //Authentication에서 사용자 정보를 추출하고 expiration을 통해 토큰 만료시간을 설정한 다음 jwt를 생성
    public String generateToken(Authentication authentication, long expiration) {
        return Jwts.builder()
            .setHeaderParam(TYPE, JWT_TYPE)
            .setClaims(generateClaims(authentication))
            .setIssuedAt(new Date(System.currentTimeMillis()))
            .setExpiration(new Date(System.currentTimeMillis() + expiration))
            .signWith(getSigningKey())
            .compact();
    }

    //토큰 검증
    public JwtValidationType validateToken(String token) {
        try {
            getBody(token);
            return JwtValidationType.VALID_JWT;
        } catch (MalformedJwtException exception) {
            log.error(exception.getMessage());
            return JwtValidationType.INVALID_JWT_TOKEN;
        } catch (ExpiredJwtException exception) {
            log.error(exception.getMessage());
            return JwtValidationType.EXPIRED_JWT_TOKEN;
        } catch (UnsupportedJwtException exception) {
            log.error(exception.getMessage());
            return JwtValidationType.UNSUPPORTED_JWT_TOKEN;
        } catch (IllegalArgumentException exception) {
            log.error(exception.getMessage());
            return JwtValidationType.EMPTY_JWT;
        }
    }

    //사용자 정보를 추출
    //jwt에 포함된 Claims을 생성
    private Claims generateClaims(Authentication authentication) {
        val claims = Jwts.claims();
        //"memberId"를 키로 하고 authentication에서 principal 정보를 추출하여 Claims에 추가해주고 이를 반환
        claims.put("memberId", authentication.getPrincipal());
        return claims;
    }

    //토큰에서 claims 정보를 추출하고 그 claims 안에 "memberId"라는 키로 저장된 값을 Long 타입으로 반환
    public Long getUserFromJwt(String token) {
        val claims = getBody(token);
        return Long.parseLong(claims.get("memberId").toString());
    }

    //토큰에서 Claims 정보를 추출
    private Claims getBody(final String token) {
        return Jwts.parserBuilder()
            .setSigningKey(getSigningKey())
            .build()
            .parseClaimsJws(token)
            .getBody();
    }

    // jwt를 서명할 때 사용되는 secretKey를 생성
    private SecretKey getSigningKey() {
        val encodedKey = getEncoder().encodeToString(valueConfig.getSecretKey().getBytes());
        return hmacShaKeyFor(encodedKey.getBytes());
    }
}
