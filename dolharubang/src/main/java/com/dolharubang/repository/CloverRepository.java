package com.dolharubang.repository;

import com.dolharubang.domain.entity.Clover;
import com.dolharubang.domain.entity.Member;
import java.time.LocalDateTime;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CloverRepository extends JpaRepository<Clover, Long> {

    //내가 보낸 클로버 리스트
    List<Clover> findBySendingMember(Member sendingMember);

    //내가 받은 클로버 리스트
    List<Clover> findByReceivingMember(Member receivingMember);

    //같은 회원에게 하루 하나 전송 + 하루에 총 7개 전송 제한을 위한 리스트
    List<Clover> findBySendingMemberAndCreatedAtBetween(Member sendingMember, LocalDateTime start, LocalDateTime end);

    boolean existsBySendingMemberAndReceivingMemberAndCreatedAtBetween(Member sendingMember, Member receivingMember, LocalDateTime start, LocalDateTime end);
}
