package com.dolharubang.controller;

import com.dolharubang.domain.dto.request.DiaryReqDto;
import com.dolharubang.domain.dto.response.DiaryResDto;
import com.dolharubang.service.DiaryService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@Tag(name = "Diaries", description = "APIs for managing diaries")
@RestController
@RequestMapping("/api/v1/diaries")
public class DiaryController {

    private final DiaryService diaryService;

    public DiaryController(DiaryService diaryService) {
        this.diaryService = diaryService;
    }

    @Operation(summary = "하루방 일기 생성하기")
    @PostMapping
    public ResponseEntity<DiaryResDto> createDiary(@RequestBody DiaryReqDto requestDto) {
        DiaryResDto response = diaryService.createDiary(requestDto);
        return ResponseEntity.ok(response);
    }
}
