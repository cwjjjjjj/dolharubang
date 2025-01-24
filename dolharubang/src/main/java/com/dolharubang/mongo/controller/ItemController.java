package com.dolharubang.mongo.controller;

import com.dolharubang.mongo.service.ItemService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
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

//    @Operation(summary = "모든 아이템 조회하가", description = "존재하는 모든 아이템을 조회한다.")
//    @GetMapping("all-items")
//    public ResponseEntity<List<Item>> getAllItems() {
//
//    }
}
