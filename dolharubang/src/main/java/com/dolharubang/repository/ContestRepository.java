package com.dolharubang.repository;

import com.dolharubang.domain.entity.Contest;
import com.dolharubang.domain.entity.Member;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ContestRepository extends JpaRepository<Contest, Long> {

    List<Contest> findAllByMember(Member member);

    Optional<Contest> findByIdAndMember(long contestNo, Member member);
    
}
