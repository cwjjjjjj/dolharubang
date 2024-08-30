package com.dolharubang.repository;

import com.dolharubang.domain.entity.Member;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MemberRepository extends JpaRepository<Member, Long> {

    /*
    모든 유저 조회
     */
    List<Member> findAllByMemberId(Long memberId);

    /*
    아이디로 유저 조회
     */
    Optional<Member> findByMemberId(Long memberId);

    /*
    닉네임으로 유저 조회
     */
    Optional<Member> findByNickname(String nickname);
}
