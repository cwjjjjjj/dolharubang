package com.dolharubang.jwt;

import com.dolharubang.domain.dto.oauth.OAuth2LoginResDto;
import com.dolharubang.domain.dto.oauth.TokenDto;
import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.oauth.PrincipalDetails;
import com.dolharubang.domain.entity.oauth.RefreshToken;
import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import com.dolharubang.repository.MemberRepository;
import com.dolharubang.repository.RefreshTokenRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class JwtService {
    private final TokenProvider tokenProvider;
    private final RefreshTokenRepository refreshTokenRepository;
    private final MemberRepository memberRepository;

    @Transactional
    public ResponseEntity<OAuth2LoginResDto> reissue(String refreshToken){

        // 1. Refresh Token 검증
        if (!tokenProvider.validateToken(refreshToken))
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED);

        // 2. Token 에서 Member ID 가져오기
        Long memberId = tokenProvider.getMemberIdFromToken(refreshToken);

        RefreshToken existRefreshToken = refreshTokenRepository.findByMemberId(memberId).orElse(null);
        if(existRefreshToken == null)
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED);

        // 3. DB에 매핑 되어있는 Member ID(key)와 Vaule값이 같지않으면 에러 리턴
        if(!refreshToken.equals(existRefreshToken.getValue()))
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED);

        Member member = memberRepository.findById(memberId).orElse(null);
        if(member == null) {
            throw new CustomException(ErrorCode.MEMBER_NOT_FOUND);
        }

        PrincipalDetails principalDetails = new PrincipalDetails(member);
        Authentication authentication = new UsernamePasswordAuthenticationToken(
            principalDetails, null, principalDetails.getAuthorities());

        // 4. Vaule값이 같다면 토큰 재발급 진행
        TokenDto tokenDto = tokenProvider.generateTokenDto(authentication);

        OAuth2LoginResDto oAuth2LoginResDto = OAuth2LoginResDto.builder()
            .accessToken(tokenDto.getAccessToken())
            .refreshToken(refreshToken)
            .build();

        System.out.println(oAuth2LoginResDto.toString());

        return ResponseEntity.ok(oAuth2LoginResDto);
    }
}
