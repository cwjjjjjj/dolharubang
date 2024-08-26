package com.dolharubang.domain.entity;

import com.dolharubang.mongo.entity.ItemType;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
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
public class HasItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long hasItemsId;

    private Long memberId;

    //TODO Item 클래스와 매칭되도록 좀 더 고민해볼 것
    private String itemName;

    private LocalDateTime receivedAt;

    @Enumerated(EnumType.STRING)
    private ItemType itemType;

    @Builder
    public HasItem(Long memberId, String itemName, LocalDateTime receivedAt, ItemType itemType) {
        this.memberId = memberId;
        this.itemName = itemName;
        this.receivedAt = receivedAt;
        this.itemType = itemType;
    }

    @PrePersist
    public void prePersist() {
        this.receivedAt = LocalDateTime.now();
    }
}
