package com.dolharubang.repository;

import com.dolharubang.domain.entity.Friend;
import com.dolharubang.domain.entity.Member;
import com.dolharubang.type.FriendStatusType;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface FriendRepository extends JpaRepository<Friend, Long> {

    // ACCEPTED 상태인 친구 목록 조회
    @Query("SELECT f FROM Friend f WHERE (f.requester = :member OR f.receiver = :member) AND f.status = :status AND f.deletedAt IS NULL")
    List<Friend> findAllFriendsByStatus(@Param("member") Member member,
        @Param("status") FriendStatusType status);

    // 내가 보내고 받은 모든 요청 목록 조회
    @Query("""
            SELECT f FROM Friend f
            WHERE (f.requester = :member OR f.receiver = :member)
              AND f.status = :status
              AND f.deletedAt IS NULL
            ORDER BY f.modifiedAt DESC
        """)
    List<Friend> findAllFriendRequests(@Param("member") Member member,
        @Param("status") FriendStatusType status);


    // 요청자와 수신자의 관계를 양방향으로 조회 (소프트 딜리트 포함)
    @Query("SELECT f FROM Friend f WHERE (f.requester = :member1 AND f.receiver = :member2 OR f.requester = :member2 AND f.receiver = :member1)")
    Friend findBetweenMembersWithDeleted(@Param("member1") Member member1,
        @Param("member2") Member member2);

    @Query("""
            SELECT f FROM Friend f
            WHERE (
                (f.requester.memberId IN :ids AND f.receiver.memberId = :myId)
                OR
                (f.receiver.memberId IN :ids AND f.requester.memberId = :myId)
            )
            AND f.deletedAt IS NULL
        """)
    List<Friend> findRelationsWithMembers(@Param("myId") Long myId, @Param("ids") List<Long> ids);


}