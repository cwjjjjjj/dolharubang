package com.dolharubang.repository;

import com.dolharubang.domain.entity.Member;
import com.dolharubang.type.Provider;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface MemberRepository extends JpaRepository<Member, Long> {

    List<Member> findByNicknameContaining(String keyword);

    Member findByProviderAndProviderId(Provider provider, String providerId);

    Optional<Member> findByNickname(String nickname);
}
