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

    // 장착 여부
    private boolean isSelected;

    @Builder
    public MemberItem(Member member, Long memberItemId, String itemId, boolean whetherHasItem, boolean isSelected) {
        this.member = member;
        this.memberItemId = memberItemId;
        this.itemId = itemId;
        this.whetherHasItem = whetherHasItem;
        this.isSelected = isSelected;
    }

    //보유 상태를 true로 변경 = 구매
    public void buyItem() {
        this.whetherHasItem = true;
    }

    //true로 바꾼 후 같은 타입의 다른 모든 item의 isSelected는 false로 변경
    public void wearItem(boolean isSelected) {
        this.isSelected = isSelected;
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
