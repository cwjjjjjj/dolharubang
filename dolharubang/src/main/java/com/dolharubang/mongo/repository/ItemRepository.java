package com.dolharubang.mongo.repository;

import com.dolharubang.mongo.entity.Item;
import com.dolharubang.mongo.enumTypes.ItemType;
import java.util.Optional;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ItemRepository extends MongoRepository<Item, String> {

    Optional<Item> findByItemId(ObjectId itemId);

    Optional<Item> findByItemType(ItemType itemType);
}
