package com.dolharubang.repository;

import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.Stone;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StoneRepository extends JpaRepository<Stone, Long> {
    Optional<Stone> findByStoneName(String stoneName);

    Optional<Stone> findByMember(Member member);

    String findSignTextByMember(Member member);
}
