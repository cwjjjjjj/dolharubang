package com.dolharubang.service;

import com.dolharubang.domain.dto.request.ItemReqDto;
import com.dolharubang.domain.dto.response.ItemResDto;
import com.dolharubang.domain.entity.Item;
import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import com.dolharubang.repository.ItemRepository;
import java.util.List;
import java.util.stream.Collectors;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
public class ItemService {

    private final ItemRepository itemRepository;

    public ItemService(ItemRepository itemRepository) {
        this.itemRepository = itemRepository;
    }

    @Transactional(readOnly = true)
    public Item findByItemId(Long itemId) {

        return itemRepository.findByItemId(itemId);
    }

    @Transactional(readOnly = true)
    public List<ItemResDto> findAll() {
        List<Item> itemList = itemRepository.findAll();
        if(itemList.isEmpty()) {
            throw new CustomException(ErrorCode.ITEM_NOT_FOUND);
        }

        return itemList.stream()
            .map(ItemResDto::fromEntity)
            .collect(Collectors.toList());
    }

    @Transactional
    public ItemResDto createItem(ItemReqDto itemReqDto) {
        Item item = Item.builder()
            .itemName(itemReqDto.getItemName())
            .itemType(itemReqDto.getItemType())
            .imageUrl(itemReqDto.getImageUrl())
            .price(itemReqDto.getPrice())
            .build();

        Item savedItem = itemRepository.save(item);
        return ItemResDto.fromEntity(savedItem);
    }

    @Transactional
    public ItemResDto updateItem(Long itemId, ItemReqDto itemDto) {
        Item item = itemRepository.findById(itemId).orElseThrow(
            () -> new CustomException(ErrorCode.ITEM_NOT_FOUND));

        Item updatedItem = Item.builder()
            .itemId(itemId)
            .itemName(itemDto.getItemName())
            .itemType(itemDto.getItemType())
            .price(itemDto.getPrice())
            .imageUrl(itemDto.getImageUrl())
            .build();

        Item savedItem = itemRepository.save(updatedItem);
        return ItemResDto.fromEntity(savedItem);
    }
}
