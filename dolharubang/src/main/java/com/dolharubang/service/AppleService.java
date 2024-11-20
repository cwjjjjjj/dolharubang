package com.dolharubang.service;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.math.BigInteger;
import java.net.HttpURLConnection;
import java.net.URL;
import java.security.KeyFactory;
import java.security.NoSuchAlgorithmException;
import java.security.PublicKey;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.RSAPublicKeySpec;
import java.util.Base64;
import java.util.Objects;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpMethod;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AppleService {

    private JsonArray getApplePublicKeys() {
        HttpURLConnection connection = sendHttpRequest();
        StringBuilder result = getHttpResponse(connection);
        JsonObject keys = (JsonObject) JsonParser.parseString(result.toString());
        return (JsonArray) keys.get("keys");
    }

    private HttpURLConnection sendHttpRequest() {
        try {
            URL url = new URL("https://appleid.apple.com/auth/keys");
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod(HttpMethod.GET.name());
            return connection;
        } catch (IOException exception) {
            throw new RuntimeException(exception);
        }
    }

    private StringBuilder getHttpResponse(HttpURLConnection connection) {
        try {
            BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(connection.getInputStream()));
            return splitHttpResponse(bufferedReader);
        } catch (IOException exception) {
            throw new RuntimeException(exception);
        }
    }

    private StringBuilder splitHttpResponse(BufferedReader bufferedReader) {
        try {
            StringBuilder result = new StringBuilder();

            String line;
            while (Objects.nonNull(line = bufferedReader.readLine())) {
                result.append(line);
            }
            bufferedReader.close();

            return result;
        } catch (IOException exception) {
            throw new RuntimeException(exception);
        }
    }

    private static final String TOKEN_VALUE_DELIMITER = "\\.";
    private static final String MODULUS = "n";
    private static final String EXPONENT = "e";
    private static final int QUOTES = 1;
    private static final int POSITIVE_NUMBER = 1;

    //socialAccessToken에서 "Bearer" 제외한 부분 디코딩
    private PublicKey makePublicKey(String accessToken, JsonArray publicKeyList) {
        String[] decodeArray = accessToken.split(TOKEN_VALUE_DELIMITER);
        String header = new String(
            Base64.getDecoder().decode(decodeArray[0].replaceFirst("Bearer ", "")));

        //kid, alg에 해당하는 부분 추출
        JsonElement kid = ((JsonObject) JsonParser.parseString(header)).get("kid");
        JsonElement alg = ((JsonObject) JsonParser.parseString(header)).get("alg");
        JsonObject matchingPublicKey = findMatchingPublicKey(publicKeyList, kid, alg);

        if (Objects.isNull(matchingPublicKey)) {
            throw new IllegalArgumentException();
        }

        return getPublicKey(matchingPublicKey);
    }


    private JsonObject findMatchingPublicKey(JsonArray publicKeyList, JsonElement kid, JsonElement alg) {
        for (JsonElement publicKey : publicKeyList) {
            JsonObject publicKeyObject = publicKey.getAsJsonObject();
            JsonElement publicKid = publicKeyObject.get("kid");
            JsonElement publicAlg = publicKeyObject.get("alg");

            if (Objects.equals(kid, publicKid) && Objects.equals(alg, publicAlg)) {
                return publicKeyObject;
            }
        }

        return null;
    }

    private PublicKey getPublicKey(JsonObject object) {
        try {
            //JSON 객체에서 MODULUS("n")와 EXPONENT("e") 키에 해당하는 값을 문자열로 추출
            String modulus = object.get(MODULUS).toString();
            String exponent = object.get(EXPONENT).toString();

            //인용부호 제거하고 디코딩
            byte[] modulusBytes = Base64.getUrlDecoder().decode(modulus.substring(QUOTES, modulus.length() - QUOTES));
            byte[] exponentBytes = Base64.getUrlDecoder().decode(exponent.substring(QUOTES, exponent.length() - QUOTES));

            //디코딩된 바이트 배열을 BigInteger로 변환
            BigInteger modulusValue = new BigInteger(POSITIVE_NUMBER, modulusBytes);
            BigInteger exponentValue = new BigInteger(POSITIVE_NUMBER, exponentBytes);

            //위에서 뽑아 낸 정보를 토대로 RSA 키 객체를 생성한다.
            RSAPublicKeySpec publicKeySpec = new RSAPublicKeySpec(modulusValue, exponentValue);
            //RSA 키 객체를 토대로 PublicKey를 생성해낸다.
            KeyFactory keyFactory = KeyFactory.getInstance("RSA");

            return keyFactory.generatePublic(publicKeySpec);
        } catch (InvalidKeySpecException | NoSuchAlgorithmException exception) {
            throw new IllegalStateException();
        }
    }

    public String getAppleData(String socialAccessToken) {
        JsonArray publicKeyList = getApplePublicKeys();
        PublicKey publicKey = makePublicKey(socialAccessToken, publicKeyList);

        //JWT에서 사용자 정보 추출
        Claims userInfo = Jwts.parserBuilder()
            .setSigningKey(publicKey)
            .build()
            .parseClaimsJws(socialAccessToken.replaceFirst("Bearer ", ""))
            .getBody();

        //JSON 객체로 변환
        JsonObject userInfoObject = (JsonObject) JsonParser.parseString(new Gson().toJson(userInfo));
        //"sub" 필드를 문자열로 추출해 변환
        return userInfoObject.get("sub").getAsString();
    }
}
