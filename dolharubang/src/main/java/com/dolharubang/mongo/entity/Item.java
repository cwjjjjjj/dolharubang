package com.dolharubang.mongo.entity;

import com.dolharubang.mongo.enumTypes.ItemType;
import jakarta.persistence.Id;
import java.time.LocalDateTime;
import java.util.Collection;
import lombok.Builder;
import lombok.Data;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

@Document(collection = "items")
@Builder
@Data
public class Item {

    @Id
    private ObjectId itemId;

    private ItemType itemType;

    private String name;

    private String url;

    private Long price;

    private String description;

    @Field
    private LocalDateTime createdAt;

    @Field
    private LocalDateTime modifiedAt;

}
