package com.dolharubang.controller.oauth;

import com.dolharubang.domain.dto.oauth.KakaoDTO;
import com.dolharubang.domain.dto.oauth.OAuth2LoginResDto;
import com.dolharubang.domain.dto.oauth.TokenDto;
import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.oauth.PrincipalDetails;
import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import com.dolharubang.jwt.TokenProvider;
import com.dolharubang.repository.MemberRepository;
import com.dolharubang.service.MemberItemService;
import com.dolharubang.service.MissionService;
import com.dolharubang.service.NotificationService;
import com.dolharubang.service.oauth.AppleService;
import com.dolharubang.service.oauth.KakaoService;
import com.dolharubang.service.oauth.RefreshTokenService;
import com.dolharubang.type.Authority;
import com.dolharubang.type.Provider;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.HashMap;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@Tag(name = "소셜 로그인 API", description = "소셜 로그인 API")
@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final KakaoService kakaoService;
    private final AppleService appleService;
    private final TokenProvider tokenProvider;
    private final RefreshTokenService refreshTokenService;
    private final MemberRepository memberRepository;
    private final MemberItemService memberItemService;
    private final NotificationService notificationService;
    private final MissionService missionService;

    @Operation(summary = "카카오 로그인", description = "카카오 로그인")
    @PostMapping("/kakao-login")
    public ResponseEntity<OAuth2LoginResDto> kakaoLogin(
        @RequestHeader(value = "Authorization") String accessToken) {
        accessToken = accessToken.substring(7);

        if (accessToken == null || accessToken.isEmpty()) {
            throw new CustomException(ErrorCode.NO_TOKEN);
        }

        KakaoDTO kakaoInfo = kakaoService.getUserInfoWithToken(accessToken);

        String provider = "KAKAO";
        String providerId = String.valueOf(kakaoInfo.getId());

        Member member = memberRepository.findByProviderAndProviderId(
            Provider.valueOf(provider), providerId);

        if (member == null) {
            String authority = "ROLE_GUEST";

            member = Member.builder()
                .authority(Authority.valueOf(authority))
                .provider(Provider.valueOf(provider))
                .providerId(providerId)
                .memberEmail(kakaoInfo.getEmail())
                .nickname(kakaoInfo.getNickname())
                .profilePicture(null)
                .sands(0)
                .closeness(0)
                .build();

            memberRepository.save(member);
            memberItemService.initializeItems(member);
            missionService.assignAllMissionsToNewMember(member);
            notificationService.sendWelcomeNotification(member);
        }

        // PrincipalDetails 생성 (인증 객체 생성)
        PrincipalDetails principalDetails = new PrincipalDetails(member, new HashMap<>());
        Authentication authentication = new UsernamePasswordAuthenticationToken(
            principalDetails, null, principalDetails.getAuthorities());

        // 토큰 생성
        TokenDto tokenDto = tokenProvider.generateTokenDto(authentication);

        // 리프레시 토큰 저장
        refreshTokenService.saveOrUpdateRefreshToken(
            member.getMemberId(),
            tokenDto.getRefreshToken()
        );

        // 응답 생성
        OAuth2LoginResDto oAuth2LoginResDto = OAuth2LoginResDto.builder()
            .accessToken(tokenDto.getAccessToken())
            .refreshToken(tokenDto.getRefreshToken())
            .build();

        System.out.println(oAuth2LoginResDto.toString());

        return ResponseEntity.ok(oAuth2LoginResDto);

    }

    @PostMapping("/apple-login")
    public ResponseEntity<OAuth2LoginResDto> appleLogin(
        @RequestHeader(value = "Authorization") String authorizationHeader,
        @RequestBody String nickname) {
        System.out.println("Authorization: " + authorizationHeader);

        String idToken = null;
        if (authorizationHeader != null && authorizationHeader.startsWith("Bearer ")) {
            idToken = authorizationHeader.substring(7);
        }

        if (idToken == null || idToken.isEmpty()) {
            throw new CustomException(ErrorCode.NO_ID_TOKEN);
        }

        // 애플 ID 토큰을 검증하고 사용자 정보 가져오기
        Map<String, Object> appleUserInfo = appleService.validateAndGetUserInfo(idToken);

        // 애플 고유 ID (sub 클레임) 추출
        String providerId = (String) appleUserInfo.get("sub");
        if (providerId == null || providerId.isEmpty()) {
            throw new CustomException(ErrorCode.INVALID_APPLE_ID);
        }

        String email = (String) appleUserInfo.get("email");

        if (nickname.trim().startsWith("{")) {
            ObjectMapper mapper = new ObjectMapper();
            try {
                nickname = mapper.readTree(nickname).get("nickname").asText();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        // 회원 조회
        Member member = memberRepository.findByProviderAndProviderId(
            Provider.APPLE, providerId);

        if (member == null) {
            // 신규 회원가입
            String authority = "ROLE_GUEST";

            member = Member.builder()
                .authority(Authority.valueOf(authority))
                .provider(Provider.APPLE)
                .providerId(providerId)
                .memberEmail(email)
                .nickname(nickname)
                .sands(0)
                .closeness(0)
                .build();

            memberRepository.save(member);
            memberItemService.initializeItems(member);
            missionService.assignAllMissionsToNewMember(member);
            notificationService.sendWelcomeNotification(member);
        }

        // PrincipalDetails 생성 (인증 객체 생성)
        PrincipalDetails principalDetails = new PrincipalDetails(member, new HashMap<>());
        Authentication authentication = new UsernamePasswordAuthenticationToken(
            principalDetails, null, principalDetails.getAuthorities());

        // 토큰 생성
        TokenDto tokenDto = tokenProvider.generateTokenDto(authentication);

        // 리프레시 토큰 저장
        refreshTokenService.saveOrUpdateRefreshToken(
            member.getMemberId(),
            tokenDto.getRefreshToken()
        );

        // 응답 생성
        boolean isGuest = member.getAuthority().equals(Authority.ROLE_GUEST);
        OAuth2LoginResDto oAuth2LoginResDto = OAuth2LoginResDto.builder()
            .accessToken(tokenDto.getAccessToken())
            .refreshToken(tokenDto.getRefreshToken())
            .build();

        return ResponseEntity.ok(oAuth2LoginResDto);

    }
}
