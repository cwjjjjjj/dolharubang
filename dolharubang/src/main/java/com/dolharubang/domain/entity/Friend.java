package com.dolharubang.domain.entity;

import com.dolharubang.type.FriendStatusType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import java.time.LocalDateTime;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.SQLDelete;
import org.hibernate.annotations.Where;

@Entity
@Getter
@Builder
@AllArgsConstructor
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@SQLDelete(sql = "UPDATE friend SET deleted_at = NOW() WHERE friend_id = ?")
@Where(clause = "deleted_at IS NULL")
public class Friend extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "friend_id")
    private Long id;

    @ManyToOne
    @JoinColumn(name = "requester_id")
    private Member requester;

    @ManyToOne
    @JoinColumn(name = "receiver_id")
    private Member receiver;

    @Enumerated(EnumType.STRING)
    private FriendStatusType status;

    private LocalDateTime acceptedAt;

    public void accept() {
        this.status = FriendStatusType.ACCEPTED;
        this.acceptedAt = LocalDateTime.now();
    }

    public void decline() {
        this.status = FriendStatusType.DECLINED;
    }

}
