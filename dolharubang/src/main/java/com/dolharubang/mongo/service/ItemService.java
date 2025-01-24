package com.dolharubang.mongo.service;

import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import com.dolharubang.mongo.entity.Item;
import com.dolharubang.mongo.repository.ItemRepository;
import java.time.LocalDateTime;
import java.util.List;
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

    public List<Item> findAll() {
        return itemRepository.findAll();
    }

    public Item saveItem(Item item) {
        item.setCreatedAt(LocalDateTime.now());
        item.setModifiedAt(LocalDateTime.now());
        return itemRepository.save(item);
    }

    public Item updateItem(String itemId, Item updateItem) {
        Item item = findByItemId(itemId)
            .orElseThrow(() -> new CustomException(ErrorCode.ITEM_NOT_FOUND));

        item.setItemType(updateItem.getItemType());
        item.setItemName(updateItem.getItemName());
        item.setImageUrl(updateItem.getImageUrl());
        item.setPrice(updateItem.getPrice());
        item.setModifiedAt(LocalDateTime.now());

        return itemRepository.save(item);
    }
}
