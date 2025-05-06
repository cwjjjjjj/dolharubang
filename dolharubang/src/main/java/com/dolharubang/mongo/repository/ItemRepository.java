package com.dolharubang.mongo.repository;

import com.dolharubang.mongo.entity.Item;
import com.dolharubang.mongo.enumTypes.ItemType;
import java.util.List;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface ItemRepository extends MongoRepository<Item, ObjectId> {

    Item findByItemId(Object itemId);

    List<Item> findByItemType(ItemType itemType);

    List<Item> findByItemName(String itemName);
}
