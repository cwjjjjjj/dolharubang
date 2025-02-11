package com.dolharubang.repository;

import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.Stone;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface StoneRepository extends JpaRepository<Stone, Long> {
    Optional<Stone> findByMember(Member member);

    @Query("SELECT s.signText FROM Stone s WHERE s.member = :member")
    String findSignTextByMember(Member member);
}
