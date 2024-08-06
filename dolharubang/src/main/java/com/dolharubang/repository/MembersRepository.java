package com.dolharubang.repository;

import com.dolharubang.domain.entity.Members;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface MembersRepository extends JpaRepository<Members, Long> {

    /*
    모든 유저 조회
     */
    List<Members> findAllByMemberEmail(String memberEmail);

    /*
    이메일로 유저 조회
     */
    @Query("SELECT m from Members m WHERE m.memberEmail = :email")
    Members findByEmail(@Param("email") String email);

    /*
    닉네임으로 유저 조회
     */
    @Query("SELECT m from Members m WHERE m.nickname = :nickname")
    Members findByNickname(@Param("nickname") String nickname);
}
