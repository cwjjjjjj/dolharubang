package com.dolharubang.repository;

import com.dolharubang.domain.entity.MemberRefreshToken;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MemberRefreshTokenRepository extends JpaRepository<MemberRefreshToken, Long> {

    MemberRefreshToken findByMemberId(Long memberId);

    MemberRefreshToken findByMemberIdAndRefreshToken(Long memberId, String refreshToken);
}
