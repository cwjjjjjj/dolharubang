package com.dolharubang.repository;

import com.dolharubang.domain.entity.Member;
import com.dolharubang.type.SocialType;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MemberRepository extends JpaRepository<Member, Long> {

    Optional<Member> findByMemberId(Long memberId);

    List<Member> findByNicknameContaining(String keyword);

    Optional<Member> findBySocialTypeAndSocialId(SocialType socialType,String socialId);
}
