package com.dolharubang.repository;

import com.dolharubang.domain.entity.Member;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface MemberRepository extends JpaRepository<Member, Long> {

    /*
    모든 유저 조회
     */
    List<Member> findAllByMemberEmail(String memberEmail);

    /*
    이메일로 유저 조회
     */
    @Query("SELECT m from Member m WHERE m.memberEmail = :email")
    Member findByEmail(@Param("email") String email);

    /*
    닉네임으로 유저 조회
     */
    @Query("SELECT m from Member m WHERE m.nickname = :nickname")
    Member findByNickname(@Param("nickname") String nickname);

}
