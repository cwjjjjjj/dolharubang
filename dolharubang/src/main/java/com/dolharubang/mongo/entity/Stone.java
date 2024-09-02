package com.dolharubang.mongo.entity;

import com.dolharubang.mongo.enumTypes.AbilityType;
import com.dolharubang.mongo.enumTypes.ItemType;
import jakarta.persistence.Id;
import java.time.LocalDateTime;
import java.util.Map;
import lombok.Builder;
import lombok.Data;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.mapping.Document;

@Document
@Builder
@Data
public class Stone {

    @Id
    private ObjectId stoneId;

    private Long memberId;

    private Long speciesId;

    private String stoneName;

    private LocalDateTime createdAt;

    private LocalDateTime modifiedAt;

    private Long closeness;

    private Map<AbilityType, Boolean> abilityAble;

    private String signText;

    //TODO Item 클래스와 매칭되도록 좀 더 고민해볼 것
    private Map<ItemType, String> custom;

}
