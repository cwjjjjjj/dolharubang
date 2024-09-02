package com.dolharubang.controller;

import com.dolharubang.domain.dto.request.HasItemReqDto;
import com.dolharubang.domain.dto.response.HasItemResDto;
import com.dolharubang.domain.entity.HasItem;
import com.dolharubang.service.HasItemService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@Tag(name = "HasItems", description = "APIs for managing hasItems")
@RestController
@RequestMapping("/api/v1/hasItems")
public class HasItemController {

    private final HasItemService hasItemService;

    public HasItemController(HasItemService hasItemService) {
        this.hasItemService = hasItemService;
    }

    @Operation(summary = "아이템 소유하기")
    @PostMapping
    public ResponseEntity<HasItemResDto> createHasItem(@RequestBody HasItemReqDto hasItemReqDto) {
        HasItemResDto response = hasItemService.createHasItem(hasItemReqDto);
        return ResponseEntity.ok(response);
    }
}
