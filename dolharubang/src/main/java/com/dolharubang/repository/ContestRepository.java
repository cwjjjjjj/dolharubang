package com.dolharubang.repository;

import com.dolharubang.domain.entity.Contest;
import com.dolharubang.domain.entity.Member;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ContestRepository extends JpaRepository<Contest, Long> {

    List<Contest> findAllByMember(Member member);

    Optional<Contest> findByIdAndMember(long contestNo, Member member);

    // 가중치 기반 추천 정렬
    @Query(value = """
        SELECT * FROM contests c
        WHERE c.is_public = true
        AND (:lastContestId IS NULL OR c.contest_id < :lastContestId)
        ORDER BY 
            (
                0.4 * RAND() +
                0.4 * EXP(-TIMESTAMPDIFF(HOUR, c.created_at, NOW()) / 24) +
                CASE 
                    WHEN c.member_id = :memberId THEN 0.05
                    ELSE 0.2
                END
            ) DESC
        LIMIT :size
        """, nativeQuery = true)
    List<Contest> findFeedContestsWithWeight(
        @Param("memberId") Long memberId,
        @Param("lastContestId") Long lastContestId,
        @Param("size") int size
    );

    // 단순 최신순 정렬
    @Query(value = """
        SELECT * FROM contests c
        WHERE c.is_public = true
        AND (:lastContestId IS NULL OR c.contest_id < :lastContestId)
        ORDER BY c.created_at DESC
        LIMIT :size
        """, nativeQuery = true)
    List<Contest> findLatestContests(
        @Param("lastContestId") Long lastContestId,
        @Param("size") int size
    );
}
