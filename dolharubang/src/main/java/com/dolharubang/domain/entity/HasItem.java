package com.dolharubang.domain.entity;

import com.dolharubang.mongo.entity.ItemType;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Entity
@Table(name = "has_items")
@Data
public class HasItem extends BaseEntity{

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long hasItemId;

    @ManyToOne
    @JoinColumn(name = "member_id")
    private Member member;

    //TODO Item 클래스와 매칭되도록 좀 더 고민해볼 것
    private String itemId;

    @Enumerated(EnumType.STRING)
    private ItemType itemType;

    @Builder
    public HasItem(Member member, String itemId, ItemType itemType) {
        this.member = member;
        this.itemId = itemId;
        this.itemType = itemType;
    }
}
