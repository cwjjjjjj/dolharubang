package com.dolharubang.mongo.entity;

import jakarta.persistence.Id;
import java.time.LocalDateTime;
import lombok.Builder;
import lombok.Data;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.mapping.Document;

@Document
@Builder
@Data
public class Item {

    @Id
    private ObjectId itemId;

    private ItemType itemType;

    private String name;

    private String url;

    private String price;

    private String description;

    private LocalDateTime createAt;

}
