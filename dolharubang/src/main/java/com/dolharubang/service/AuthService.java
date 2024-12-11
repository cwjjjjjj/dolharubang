package com.dolharubang.service;

import com.dolharubang.domain.dto.request.SignInReqDto;
import com.dolharubang.domain.dto.response.SignInResDto;
import com.dolharubang.domain.entity.Member;
import com.dolharubang.jwt.JwtTokenProvider;
import com.dolharubang.jwt.Token;
import com.dolharubang.jwt.UserAuthentication;
import com.dolharubang.repository.MemberRepository;
import com.dolharubang.type.SocialType;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AuthService {

    @Value("${jwt.access.expiration}")
    private int ACCESS_TOKEN_EXPIRATION;

    @Value("${jwt.refresh.expiration}")
    private int REFRESH_TOKEN_EXPIRATION;

    private final JwtTokenProvider jwtTokenProvider;
    private final MemberRepository memberRepository;
    private final AppleService appleService;
    private final KakaoService kakaoService;

    @Transactional
    public SignInResDto signIn(String socialAccessToken, SignInReqDto request) {
        Member member = getMember(socialAccessToken, request);
        Token token = getToken(member);
        return SignInResDto.of(token);
    }

    @Transactional
    public void signOut(Long memberId) {
        Member member = findMember(memberId);
        member.resetRefreshToken();
    }

    @Transactional
    public void withdraw(Long memberId) {
        Member member = findMember(memberId);
        deleteMember(member);
    }

    //클라이언트에서 받은 socialAccessToken을 통해 apple 또는 kakao 서버와 통신해 사용자 정보 얻어옴
    private Member getMember(String socialAccessToken, SignInReqDto request) {
        SocialType socialType = request.socialType();
        String socialId = getSocialId(socialAccessToken, socialType);
        return signUp(socialType, socialId);
    }

    private String getSocialId(String socialAccessToken, SocialType socialType) {
        return switch (socialType) {
            case APPLE -> appleService.getAppleData(socialAccessToken);
            case KAKAO -> kakaoService.getKakaoData(socialAccessToken);
        };
    }

    private Member signUp(SocialType socialType, String socialId) {
        return memberRepository.findBySocialTypeAndSocialId(socialType, socialId)
            .orElseGet(() -> saveMember(socialType, socialId));
    }

    private Member saveMember(SocialType socialType, String socialId) {
        Member member = Member.builder()
            .socialType(socialType)
            .socialId(socialId)
            .build();
        return memberRepository.save(member);
    }

    //사용자 정보를 통해 refreshToken을 Member에 저장해주고 Token을 가져옴
    private Token getToken(Member member) {
        Token token = generateToken(new UserAuthentication(member.getMemberId(), null, null));
        member.updateRefreshToken(token.getRefreshToken());
        return token;
    }

    private Token generateToken(Authentication authentication) {
        return Token.builder()
            .accessToken(jwtTokenProvider.generateToken(authentication, ACCESS_TOKEN_EXPIRATION))
            .refreshToken(jwtTokenProvider.generateToken(authentication, REFRESH_TOKEN_EXPIRATION))
            .build();
    }

    private Member findMember(long id) {
        return memberRepository.findById(id)
            .orElseThrow();
    }

    private void deleteMember(Member member) {
        memberRepository.delete(member);
    }
}
