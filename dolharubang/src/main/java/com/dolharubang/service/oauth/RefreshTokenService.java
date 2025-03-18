package com.dolharubang.service.oauth;

import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.oauth.RefreshToken;
import com.dolharubang.repository.MemberRepository;
import com.dolharubang.repository.RefreshTokenRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class RefreshTokenService {

    private final RefreshTokenRepository refreshTokenRepository;
    private final MemberRepository memberRepository;

    @Transactional
    public void saveOrUpdateRefreshToken(Long memberId, String tokenValue) {
        // 트랜잭션 내에서 Member 조회
        Member member = memberRepository.findById(memberId)
            .orElseThrow(() -> new RuntimeException("Member not found"));

        // 해당 멤버의 RefreshToken 조회
        RefreshToken existRefreshToken = refreshTokenRepository.findByMemberId(memberId).orElse(null);

        if (existRefreshToken == null) {
            // 없으면 새로 생성
            RefreshToken refreshToken = RefreshToken.builder()
                .member(member)
                .value(tokenValue)
                .build();
            refreshTokenRepository.save(refreshToken);
        } else {
            // 있으면 업데이트
            existRefreshToken.updateValue(tokenValue);
            refreshTokenRepository.save(existRefreshToken);
        }
    }
}