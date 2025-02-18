package com.dolharubang.mongo.dto;

import com.dolharubang.mongo.entity.Item;
import com.dolharubang.mongo.enumTypes.ItemType;
import java.time.LocalDateTime;
import lombok.Data;
import org.bson.types.ObjectId;

@Data
public class ItemDto {
    private String itemId;
    private ItemType itemType;
    private String itemName;
    private String imageUrl;
    private int price;
    private LocalDateTime createdAt;
    private LocalDateTime modifiedAt;

    public static ItemDto fromEntity(Item item) {
        ItemDto dto = new ItemDto();
        dto.setItemId(item.getItemId().toHexString());
        dto.setItemType(item.getItemType());
        dto.setItemName(item.getItemName());
        dto.setImageUrl(item.getImageUrl());
        dto.setPrice(item.getPrice());
        dto.setCreatedAt(item.getCreatedAt());
        dto.setModifiedAt(item.getModifiedAt());
        return dto;
    }

    public Item toEntity() {
        return Item.builder()
            .itemId(itemId != null ? new ObjectId(itemId) : null)
            .itemType(itemType)
            .itemName(itemName)
            .imageUrl(imageUrl)
            .price(price)
            .createdAt(createdAt)
            .modifiedAt(modifiedAt)
            .build();
    }
}