package com.dolharubang.mongo.service;

import com.dolharubang.mongo.entity.Item;
import com.dolharubang.mongo.entity.Stone;
import com.dolharubang.mongo.enumTypes.AbilityType;
import com.dolharubang.mongo.enumTypes.ItemType;
import java.time.LocalDateTime;
import java.util.Map;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.stereotype.Service;

@Service
public class ItemService {

    @Autowired
    private MongoTemplate mongoTemplate;

    public void createAndFetchItems() {

        System.out.println("createAndFetchItems 실행");
        // Item 객체 생성 및 저장
        Item item = Item.builder()
            .itemId(new ObjectId())
            .itemType(ItemType.BACKGROUND)  // 실제 Enum 값으로 변경
            .name("Sample Item")
            .url("http://example.com")
            .price(100L)
            .description("Sample description")
            .createdAt(LocalDateTime.now())
            .modifiedAt(LocalDateTime.now())
            .build();

        mongoTemplate.save(item, "items");
        System.out.println("아이템 ID: " + item.getItemId());

        // Stone 객체 생성 및 저장
        Stone stone = Stone.builder()
            .stoneId(new ObjectId())
            .memberId(123L)
            .speciesId(456L)
            .stoneName("Sample Stone")
            .createdAt(LocalDateTime.now())
            .modifiedAt(LocalDateTime.now())
            .closeness(10L)
            .abilityAble(Map.of(AbilityType.ADVISOR, true))  // 실제 Enum 값으로 변경
            .signText("Sample Sign")
            .custom(Map.of(ItemType.BACKGROUND, "Custom Value"))  // 실제 Enum 값으로 변경
            .build();

        mongoTemplate.save(stone, "stones");
        System.out.println("돌 ID: " + stone.getStoneId());

        // 데이터를 조회하여 구조 확인
        Item retrievedItem = mongoTemplate.findById(item.getItemId(), Item.class, "Item");
        Stone retrievedStone = mongoTemplate.findById(stone.getStoneId(), Stone.class, "Stone");

        System.out.println(retrievedItem);
        System.out.println(retrievedStone);
    }
}