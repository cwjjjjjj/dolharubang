package com.dolharubang.repository;

import com.dolharubang.domain.entity.Notification;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface NotificationRepository extends JpaRepository<Notification, Long> {

    long countByReceiverIdAndIsReadFalse(Long receiverId);

    Optional<Notification> findByIdAndReceiverId(Long id, Long receiverId);

    @Query("SELECT n FROM Notification n JOIN FETCH n.requester WHERE n.receiverId = :receiverId")
    Page<Notification> findByReceiverIdWithRequester(@Param("receiverId") Long receiverId,
        Pageable pageable);

    @Query("SELECT n FROM Notification n JOIN FETCH n.requester WHERE n.receiverId = :receiverId AND n.isRead = false")
    Page<Notification> findByReceiverIdAndIsReadFalseWithRequester(
        @Param("receiverId") Long receiverId, Pageable pageable);


}
