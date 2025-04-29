package com.dolharubang.repository;

import com.dolharubang.domain.entity.Member;
import com.dolharubang.type.Provider;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MemberRepository extends JpaRepository<Member, Long> {

    List<Member> findByNicknameContaining(String keyword);

    Member findByProviderAndProviderId(Provider provider, String providerId);

    List<Member> findByNickname(String nickname);
}
