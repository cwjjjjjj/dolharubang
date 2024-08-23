package com.dolharubang.domain.entity;

import com.dolharubang.mongo.entity.ItemType;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import lombok.AccessLevel;
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

    private String itemName;

    @Enumerated(EnumType.STRING)
    private ItemType itemtype;

    private LocalDateTime receivedAt;

}
