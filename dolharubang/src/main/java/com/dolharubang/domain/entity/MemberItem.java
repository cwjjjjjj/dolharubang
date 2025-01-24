package com.dolharubang.domain.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import java.time.LocalDateTime;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Entity
@Getter
public class MemberItem extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long memberItemId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    private String itemId;

    // 보유 여부
    private boolean whetherHasItem;

    @Builder
    public MemberItem(Member member, Long memberItemId, String itemId, boolean whetherHasItem) {
        this.member = member;
        this.memberItemId = memberItemId;
        this.itemId = itemId;
        this.whetherHasItem = whetherHasItem;
    }

    public void update(Member member, String itemId, boolean whetherHasItem) {
        this.member = member;
        this.itemId = itemId;
        this.whetherHasItem = whetherHasItem;
    }

    //엔티티가 영속성 컨텍스트에 저장되기 전에 호출
    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.modifiedAt = LocalDateTime.now();
    }

    //엔티티가 영속성 컨텍스트에 업데이트되기 전에 호출
    @PreUpdate
    protected void onUpdate() {
        this.modifiedAt = LocalDateTime.now();
    }
}
