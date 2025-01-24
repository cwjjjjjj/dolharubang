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

    private Long price;

    @Field
    private LocalDateTime createdAt;

    @Field
    private LocalDateTime modifiedAt;
}
