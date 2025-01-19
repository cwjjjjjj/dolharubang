package com.dolharubang.repository;

import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.Stone;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StoneRepository extends JpaRepository<Stone, Long> {
    Optional<Stone> findByName(String name);

    Optional<Stone> findByMemberId(Long memberId);

    Optional<Stone> findByMember(Member member);

    Optional<String> findSignTextByMember(Member member);
}
