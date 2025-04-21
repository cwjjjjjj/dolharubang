package com.dolharubang.service.oauth;

import com.dolharubang.config.oauth.AppleProperties;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigInteger;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.security.KeyFactory;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.RSAPublicKeySpec;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Base64;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Slf4j
@Service
@RequiredArgsConstructor
public class AppleService {

    private final AppleProperties appleProperties;
    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;

    /**
     * 애플 ID 토큰을 검증하고 사용자 정보를 추출합니다.
     *
     * @param idToken 애플에서 제공한 ID 토큰
     * @return 사용자 정보를 담은 Map 객체
     */
    public Map<String, Object> validateAndGetUserInfo(String idToken) {
        try {
            // 1. ID 토큰 디코딩 및 기본 검증
            Map<String, Object> claims = decodeJwtTokenPayload(idToken);

            // 2. 토큰 발급자 검증
            String issuer = (String) claims.get("iss");
            if (!"https://appleid.apple.com".equals(issuer)) {
                throw new IllegalArgumentException("Invalid token issuer: " + issuer);
            }

            // 3. 클라이언트 ID 검증
            String audience = (String) claims.get("aud");
            if (!appleProperties.getCid().equals(audience)) {
                throw new IllegalArgumentException("Invalid audience: " + audience);
            }

            // 4. 토큰 만료 시간 검증
            Long expirationTime = (Long) claims.get("exp");
            if (expirationTime < (System.currentTimeMillis() / 1000)) {
                throw new IllegalArgumentException("Token has expired");
            }

            // 5. 사용자 정보 추출 및 반환 (claims 그대로 반환)
            return claims;

        } catch (Exception e) {
            log.error("애플 ID 토큰 검증 실패: {}", e.getMessage());
            throw new RuntimeException("Failed to validate Apple ID token", e);
        }
    }

    /**
     * 애플 공개 키를 가져와 지정된 kid와 일치하는 키를 반환합니다.
     *
     * @param kid 키 ID
     * @return 애플 공개 키
     */
    @Cacheable(value = "applePublicKeys", key = "#kid")
    public PublicKey getApplePublicKey(String kid) throws Exception {
        // 애플 공개 키 엔드포인트 호출
        Map response = restTemplate.getForObject(
            "https://appleid.apple.com/auth/keys",
            Map.class
        );

        // 키 목록 추출
        List<Map<String, String>> keys = (List<Map<String, String>>) response.get("keys");

        // kid와 일치하는 키 찾기
        Map<String, String> key = keys.stream()
            .filter(k -> kid.equals(k.get("kid")))
            .findFirst()
            .orElseThrow(
                () -> new IllegalArgumentException("No matching key found for kid: " + kid));

        // RSA 공개 키 생성
        String modulus = key.get("n");
        String exponent = key.get("e");

        BigInteger n = new BigInteger(1, Base64.getUrlDecoder().decode(modulus));
        BigInteger e = new BigInteger(1, Base64.getUrlDecoder().decode(exponent));

        RSAPublicKeySpec publicKeySpec = new RSAPublicKeySpec(n, e);
        KeyFactory keyFactory = KeyFactory.getInstance("RSA");

        return keyFactory.generatePublic(publicKeySpec);
    }

    /**
     * 클라이언트 시크릿 생성 (서버-서버 통신에 필요한 경우) 일부 애플 API 호출 시 클라이언트 시크릿이 필요할 수 있습니다.
     *
     * @return 생성된 클라이언트 시크릿
     */
    public String createClientSecret() {
        try {
            // 개인 키 로드
            PrivateKey privateKey = loadPrivateKey();

            // 헤더 설정
            Map<String, Object> header = new HashMap<>();
            header.put("kid", appleProperties.getKid());
            header.put("alg", "ES256");

            // 현재 시간과 만료 시간 설정
            LocalDateTime now = LocalDateTime.now();
            LocalDateTime expiration = now.plusMinutes(5); // 5분 후 만료

            // JWT 클레임 생성 및 서명
            String clientSecret = Jwts.builder()
                .setHeader((Map<String, Object>) header)
                .setIssuer(appleProperties.getTid()) // Team ID
                .setIssuedAt(Date.from(now.atZone(ZoneId.systemDefault()).toInstant()))
                .setExpiration(Date.from(expiration.atZone(ZoneId.systemDefault()).toInstant()))
                .setAudience("https://appleid.apple.com")
                .setSubject(appleProperties.getCid()) // Client ID
                .signWith(privateKey, SignatureAlgorithm.ES256)
                .compact();

            return clientSecret;

        } catch (Exception e) {
            log.error("애플 클라이언트 시크릿 생성 실패: {}", e.getMessage());
            throw new RuntimeException("Failed to create Apple client secret", e);
        }
    }

    /**
     * 애플 개인 키 파일을 로드합니다.
     *
     * @return 애플 개인 키
     */
    private PrivateKey loadPrivateKey() throws Exception {
        // 개인 키 파일 경로
        String keyPath = appleProperties.getPath();

        InputStream keyInputStream = null;
        try {
            // 먼저 파일 시스템에서 시도
            if (Files.exists(Paths.get(keyPath))) {
                keyInputStream = Files.newInputStream(Paths.get(keyPath));
            } else {
                // 클래스패스에서 시도
                Resource resource = new ClassPathResource(keyPath);
                keyInputStream = resource.getInputStream();
            }

            // PEM 파일 내용 읽기
            String pemContent = new String(keyInputStream.readAllBytes(), StandardCharsets.UTF_8);

            // PEM 헤더/푸터 제거 및 개행 문자 제거
            String privateKeyPEM = pemContent
                .replace("-----BEGIN PRIVATE KEY-----", "")
                .replace("-----END PRIVATE KEY-----", "")
                .replace("-----BEGIN EC PRIVATE KEY-----", "")
                .replace("-----END EC PRIVATE KEY-----", "")
                .replaceAll("\\s", "");

            // Base64 디코딩
            byte[] encodedKey = Base64.getDecoder().decode(privateKeyPEM);

            // PKCS8 형식의 개인 키 생성
            PKCS8EncodedKeySpec keySpec = new PKCS8EncodedKeySpec(encodedKey);
            KeyFactory keyFactory = KeyFactory.getInstance("EC");  // 애플은 EC 알고리즘 사용

            return keyFactory.generatePrivate(keySpec);

        } catch (Exception e) {
            log.error("애플 개인 키 로드 실패: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to load Apple private key", e);
        } finally {
            if (keyInputStream != null) {
                try {
                    keyInputStream.close();
                } catch (IOException e) {
                    log.warn("Failed to close key input stream", e);
                }
            }
        }
    }

    /**
     * JWT 토큰의 페이로드 부분을 디코딩하여 클레임 정보를 맵으로 반환합니다.
     *
     * @param jwtToken JWT 토큰 문자열
     * @return 디코딩된 클레임 정보가 담긴 Map
     */
    public Map<String, Object> decodeJwtTokenPayload(String jwtToken) {
        Map<String, Object> jwtClaims = new HashMap<>();
        try {
            String[] parts = jwtToken.split("\\.");
            Base64.Decoder decoder = Base64.getUrlDecoder();

            byte[] decodedBytes = decoder.decode(parts[1].getBytes(StandardCharsets.UTF_8));
            String decodedString = new String(decodedBytes, StandardCharsets.UTF_8);
            ObjectMapper mapper = new ObjectMapper();

            Map<String, Object> map = mapper.readValue(decodedString, Map.class);
            jwtClaims.putAll(map);

        } catch (JsonProcessingException e) {
//        logger.error("decodeJwtToken: {}-{} / jwtToken : {}", e.getMessage(), e.getCause(), jwtToken);
        }
        return jwtClaims;
    }
}
