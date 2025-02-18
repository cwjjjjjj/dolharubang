package com.dolharubang.mongo.entity;

import com.dolharubang.mongo.enumTypes.ItemType;
import jakarta.persistence.Id;
import java.time.LocalDateTime;
import lombok.Builder;
import lombok.Data;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.mapping.Field;

@Builder
@Data
public class Item {

    @Id
    @Field(name = "_id")
    private ObjectId itemId;

    private ItemType itemType;

    private String itemName;

    private String imageUrl;

    private int price;

    @Field
    private LocalDateTime createdAt;

    @Field
    private LocalDateTime modifiedAt;

    public Item update(ItemType itemType, String itemName, String imageUrl, int price) {
        return Item.builder()
            .itemId(this.itemId)
            .itemType(itemType)
            .itemName(itemName)
            .imageUrl(imageUrl)
            .price(price)
            .createdAt(this.createdAt)
            .modifiedAt(LocalDateTime.now())
            .build();
    }
}
