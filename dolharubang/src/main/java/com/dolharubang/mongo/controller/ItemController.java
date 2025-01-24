package com.dolharubang.mongo.controller;

import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import com.dolharubang.mongo.dto.ItemDto;
import com.dolharubang.mongo.entity.Item;
import com.dolharubang.mongo.service.ItemService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
@Slf4j
@Tag(name = "Items", description = "APIs for managing items")
@RestController
@RequestMapping("/api/v1/items")
public class ItemController {

    private final ItemService itemService;

    public ItemController(ItemService itemService) {
        this.itemService = itemService;
    }

    @Operation(summary = "모든 아이템 조회하기", description = "존재하는 모든 아이템을 조회한다.")
    @GetMapping("all-items")
    public ResponseEntity<List<ItemDto>> getAllItems() {
        List<Item> items = itemService.findAll();
        return ResponseEntity.ok(items.stream()
            .map(ItemDto::fromEntity)
            .toList());
    }

    @Operation(summary = "새로운 아이템 추가하기", description = "아이템을 추가한다.")
    @PostMapping("/add")
    public ResponseEntity<ItemDto> addItem(@RequestBody ItemDto itemDto) {
        Item savedItem = itemService.saveItem(itemDto.toEntity());
        return ResponseEntity.status(HttpStatus.CREATED).body(ItemDto.fromEntity(savedItem));
    }

    @Operation(summary = "아이템 상세 조회하기", description = "하나의 아이템을 조회한다.")
    @GetMapping("/{itemId}")
    public ResponseEntity<ItemDto> getItem(@PathVariable String itemId) {
        return ResponseEntity.ok(ItemDto.fromEntity(
            itemService.findByItemId(itemId)
                .orElseThrow(() -> new CustomException(ErrorCode.ITEM_NOT_FOUND))
        ));
    }

    @Operation(summary = "아이템 수정하기", description = "하나의 아이템을 수정한다.")
    @PutMapping("/{itemId}")
    public ResponseEntity<ItemDto> updateItem(@PathVariable String itemId, @RequestBody ItemDto itemDto) {
        Item updatedItem = itemService.updateItem(itemId, itemDto.toEntity());
        return ResponseEntity.ok(ItemDto.fromEntity(updatedItem));
    }
}