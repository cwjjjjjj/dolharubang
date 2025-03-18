package com.dolharubang.config.oauth;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import java.io.IOException;
import java.io.InputStream;
import java.io.StringReader;
import java.nio.charset.StandardCharsets;
import java.security.PrivateKey;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import lombok.Getter;
import org.apache.commons.io.IOUtils;
import org.bouncycastle.asn1.pkcs.PrivateKeyInfo;
import org.bouncycastle.openssl.PEMParser;
import org.bouncycastle.openssl.jcajce.JcaPEMKeyConverter;
import org.springframework.core.convert.converter.Converter;
import org.springframework.core.io.ClassPathResource;
import org.springframework.http.RequestEntity;
import org.springframework.security.oauth2.client.endpoint.OAuth2AuthorizationCodeGrantRequest;
import org.springframework.security.oauth2.client.endpoint.OAuth2AuthorizationCodeGrantRequestEntityConverter;
import org.springframework.stereotype.Component;
import org.springframework.util.MultiValueMap;

@Getter
@Component
public class CustomRequestEntityConverter implements
    Converter<OAuth2AuthorizationCodeGrantRequest, RequestEntity<?>> {
    private final OAuth2AuthorizationCodeGrantRequestEntityConverter defaultConverter;
    private final String path;
    private final String keyId;
    private final String teamId;
    private final String clientId;
    private final String url;

    /*
        CustomRequestEntityConverter 속성들에는 인가코드를 RequestEntity로 변환시켜주는 OAuth2AuthorizationCodeGrantRequestEntityConverter객체와 애플 개발자 서비스 관련 정보들이 존재
        AppProperties와 컨버터를 주입하여 해당 클래스 내에서 사용할 수 있게 함
     */
    public CustomRequestEntityConverter(AppleProperties properties) {
        this.defaultConverter = new OAuth2AuthorizationCodeGrantRequestEntityConverter();
        this.path = properties.getPath();
        this.keyId = properties.getKid();
        this.teamId = properties.getTid();
        this.clientId = properties.getCid();
        this.url = properties.getUrl();
    }

    /*
        defaultConverter를 이용하여 인가코드를 담고있는 객체를 RequestEntity로 변환
        인가코드 객체에서 provider가 어디인지 찾은 후 분기
        provider가 apple일 경우에만 client_secret을 생성하는 로직이 적용,
        그렇지 않은 경우 인가코드를 담고 있는 객체만 RequestEntity로 변환되어 Resource서버에 엑세스 토큰을 요청
     */
    @Override
    public RequestEntity<?> convert(OAuth2AuthorizationCodeGrantRequest req) {
        RequestEntity<?> entity = defaultConverter.convert(req);
        String registrationId = req.getClientRegistration().getRegistrationId();
        MultiValueMap<String, String> params = (MultiValueMap<String, String>) entity.getBody();

        if (registrationId.contains("apple")) {
            try {
                params.set("client_secret", createClientSecret());
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }
        return new RequestEntity<>(params, entity.getHeaders(),
            entity.getMethod(), entity.getUrl());
    }

    /*
        client_secret 생성 시 서명에 사용되는 privateKey를 생성
        PemParser와 JcaPEMKeyConverter를 활용하여 -----BEGIN PRIVATE KEY----- 과 같은 부분과 공백을 제거 후 리턴
     */
    public PrivateKey getPrivateKey() throws IOException {

        ClassPathResource resource = new ClassPathResource(path);

        InputStream in = resource.getInputStream();
        PEMParser pemParser = new PEMParser(new StringReader(IOUtils.toString(in, StandardCharsets.UTF_8)));
        PrivateKeyInfo object = (PrivateKeyInfo) pemParser.readObject();
        JcaPEMKeyConverter converter = new JcaPEMKeyConverter();
        return converter.getPrivateKey(object);
    }

    /*
        client_secret을 생성
        헤더에는 AppProperties에 존재하는 keyId와 JWT 서명 알고리즘을 명시
        발행인, 발행시간, 만료시간, 요청url, Client_id, privateKey를 담은 JWT를 생성
     */
    public String createClientSecret() throws IOException {
        Map<String, Object> jwtHeader = new HashMap<>();
        jwtHeader.put("kid", keyId);
        jwtHeader.put("alg", "ES256");

        return Jwts.builder()
            .setHeaderParams(jwtHeader)
            .setIssuer(teamId)
            .setIssuedAt(new Date(System.currentTimeMillis())) // 발행 시간 - UNIX 시간
            .setExpiration(new Date(System.currentTimeMillis() + (1000 * 60 * 5)))// 만료 시간
            .setAudience(url)
            .setSubject(clientId)
            .signWith(getPrivateKey(), SignatureAlgorithm.ES256)
            .compact();
    }
}