package com.dolharubang.mongo.service;

import com.dolharubang.mongo.entity.Item;
import com.dolharubang.mongo.repository.ItemRepository;
import java.util.Optional;
import org.bson.types.ObjectId;
import org.springframework.stereotype.Service;

@Service
public class ItemService {

    private final ItemRepository itemRepository;

    public ItemService(ItemRepository itemRepository) {
        this.itemRepository = itemRepository;
    }

    //String으로 전달된 itemId를 objectId로 변환 후 Item 조회
    public Optional<Item> findByItemId(String itemId) {
        ObjectId objectId = new ObjectId(itemId);

        return itemRepository.findByItemId(objectId);
    }
}
