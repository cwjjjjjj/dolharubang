package com.dolharubang.mongo.service;

import com.dolharubang.mongo.entity.Item;
import com.dolharubang.mongo.repository.ItemRepository;
import java.time.LocalDateTime;
import java.util.List;
import org.bson.types.ObjectId;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ItemService {

    private final ItemRepository itemRepository;

    public ItemService(ItemRepository itemRepository) {
        this.itemRepository = itemRepository;
    }

    //String으로 전달된 itemId를 objectId로 변환 후 Item 조회
    @Transactional(readOnly = true)
    public Item findByItemId(String itemId) {
        ObjectId objectId = new ObjectId(itemId);

        return itemRepository.findByItemId(objectId);
    }

    @Transactional(readOnly = true)
    public List<Item> findAll() {
        return itemRepository.findAll();
    }

    @Transactional
    public Item saveItem(Item item) {
        item.setCreatedAt(LocalDateTime.now());
        item.setModifiedAt(LocalDateTime.now());
        return itemRepository.save(item);
    }

    @Transactional
    public Item updateItem(String itemId, Item updateItem) {
        Item item = findByItemId(itemId);

        return itemRepository.save(item.update(
            updateItem.getItemType(),
            updateItem.getItemName(),
            updateItem.getImageUrl(),
            updateItem.getPrice()
        ));
    }
}
