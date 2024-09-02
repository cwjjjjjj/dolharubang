package com.dolharubang.repository;

import com.dolharubang.domain.entity.HasItem;
import com.dolharubang.domain.entity.Member;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface HasItemRepository extends JpaRepository<HasItem, Long> {

    Optional<HasItem> findByHasItemId(Long hasItemId);

    Optional<HasItem> findAllByMember(Member member);
}
