package com.dolharubang.controller;

import com.dolharubang.domain.dto.request.StoneReqDto;
import com.dolharubang.domain.dto.response.StoneResDto;
import com.dolharubang.service.StoneService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@Tag(name = "stones", description = "APIs for managing stones")
@RestController
@RequestMapping("/api/v1/stones")
public class StoneController {

    private final StoneService stoneService;

    public StoneController(StoneService stoneService) {
        this.stoneService = stoneService;
    }

    @Operation(summary = "돌 입양하기", description = "돌을 입양한다.")
    @PostMapping
    public ResponseEntity<StoneResDto> addStone(@RequestBody StoneReqDto requestDto) {
        StoneResDto response = stoneService.adoptStone(requestDto);

        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

//    @Operation(summary = "팻말 문구 조회하기", description = "팻말 문구의 내용을 조회한다.")
//    @GetMapping(path = "/sign-text/{memberId}", produces = "application/json")
//    public Map<String, String> readSignText(@PathVariable Long memberId) {
//        Map<String, String> response = new HashMap<>();
//        response.put("signText", stoneService.readSignText(memberId));
//        return response;
//    }
}
