package com.dolharubang.controller;

import com.dolharubang.domain.dto.response.memberItem.MemberItemResDto;
import com.dolharubang.service.MemberItemService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@Tag(name = "MemberItems", description = "APIs for managing memberItems")
@RestController
@RequestMapping("/api/v1/memberItems")
public class MemberItemController {

    private final MemberItemService memberItemService;

    public MemberItemController(MemberItemService memberItemService) {
        this.memberItemService = memberItemService;
    }

    @Operation(summary = "아이템 구매하기", description = "memberId와 아이템을 사용하여 아이템을 구매상태로 변경한다.")
    @PostMapping("/buy/{memberId}")
    public ResponseEntity<MemberItemResDto> buyMemberItem(@PathVariable Long memberId,
        @RequestParam String itemId) {
        MemberItemResDto response = memberItemService.updateItemOwnership(memberId, itemId);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "아이템 조회하기", description = "memberId를 사용하여 아이템을 조회한다.")
    @GetMapping("/{memberId}")
    public ResponseEntity<List<MemberItemResDto>> getAllMemberItem(@PathVariable Long memberId) {
        List<MemberItemResDto> response = memberItemService.getMemberItem(memberId);

        return ResponseEntity.ok(response);
    }
}
