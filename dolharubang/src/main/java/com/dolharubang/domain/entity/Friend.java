package com.dolharubang.domain.entity;

import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
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

@Entity
@Getter
@Builder
@AllArgsConstructor
@NoArgsConstructor(access = AccessLevel.PROTECTED)
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

    public void delete() {
        this.status = FriendStatusType.DELETED;
        this.deletedAt = LocalDateTime.now();
    }

    public void restore(Member requester, Member receiver) {
        this.requester = requester;
        this.receiver = receiver;
        this.status = FriendStatusType.PENDING;
        this.deletedAt = null;
    }

    public void cancel() {
        if (this.status != FriendStatusType.PENDING) {
            throw new CustomException(ErrorCode.FRIEND_CANNOT_BE_CANCEL);
        }
        this.status = FriendStatusType.CANCELED;
        this.deletedAt = LocalDateTime.now();
    }

}
