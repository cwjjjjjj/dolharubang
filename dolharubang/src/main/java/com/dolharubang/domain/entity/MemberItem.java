package com.dolharubang.domain.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Entity
@Table(name = "member_items")
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
}
