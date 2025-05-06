package com.dolharubang.controller;

import com.dolharubang.domain.dto.request.ItemReqDto;
import com.dolharubang.domain.dto.response.ItemResDto;
import com.dolharubang.service.ItemService;
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
    public ResponseEntity<List<ItemResDto>> getAllItems() {
        List<ItemResDto> response = itemService.findAll();

        return ResponseEntity.ok(response);
    }

    @Operation(summary = "새로운 아이템 추가하기", description = "아이템을 추가한다.")
    @PostMapping("/add")
    public ResponseEntity<ItemResDto> addItem(@RequestBody ItemReqDto itemReqDto) {
        ItemResDto response = itemService.createItem(itemReqDto);

        return ResponseEntity.status(HttpStatus.OK).body(response);
    }

    @Operation(summary = "아이템 상세 조회하기", description = "하나의 아이템을 조회한다.")
    @GetMapping("/{itemId}")
    public ResponseEntity<ItemResDto> getItem(@PathVariable Long itemId) {
        return ResponseEntity.ok(ItemResDto.fromEntity(
            itemService.findByItemId(itemId)));
    }

    @Operation(summary = "아이템 수정하기", description = "하나의 아이템을 수정한다.")
    @PutMapping("/{itemId}")
    public ResponseEntity<ItemResDto> updateItem(@PathVariable Long itemId, @RequestBody ItemReqDto itemDto) {
        ItemResDto response = itemService.updateItem(itemId, itemDto);
        return ResponseEntity.ok(response);
    }
}
