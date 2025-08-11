package com.dolharubang.domain.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Builder
@Getter
@AllArgsConstructor
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Clover extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long cloverId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sending_member_id", nullable = false)
    private Member sendingMember;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "receiving_member_id", nullable = false)
    private Member receivingMember;

    //TODO 답장 여부 추후 구현
//    private boolean isReplied;
    //createdAt이 보낸 시간
    //modifiedAt이 답장 시간

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.modifiedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        this.modifiedAt = LocalDateTime.now();
    }
}
