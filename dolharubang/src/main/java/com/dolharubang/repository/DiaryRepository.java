package com.dolharubang.repository;

import com.dolharubang.domain.entity.Diary;
import com.dolharubang.domain.entity.Member;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DiaryRepository extends JpaRepository<Diary, Long> {
    Optional<Diary> findByDiaryId(Long diaryId);

    List<Diary> findAllByMember(Member member);

    List<Diary> findAllByMemberAndCreatedAtBetween(Member member, LocalDateTime start, LocalDateTime end);
}
