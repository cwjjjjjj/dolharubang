package com.dolharubang.repository;

import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.MemberItem;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MemberItemRepository extends JpaRepository<MemberItem, Long> {

    boolean existsByMemberAndItemId(Member member, Long itemId);

    Optional<MemberItem> findByMemberAndItemId(Member member, Long itemId);

    List<MemberItem> findAllByMember(Member member);
}
