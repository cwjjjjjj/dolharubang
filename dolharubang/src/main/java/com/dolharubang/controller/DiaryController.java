package com.dolharubang.controller;

import com.dolharubang.domain.dto.request.DiaryReqDto;
import com.dolharubang.domain.dto.response.DiaryResDto;
import com.dolharubang.service.DiaryService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
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

    @Operation(summary = "하루방 일기 생성하기", description = "하루방 일기를 생성한다.")
    @PostMapping
    public ResponseEntity<DiaryResDto> createDiary(@RequestBody DiaryReqDto requestDto) {
        DiaryResDto response = diaryService.createDiary(requestDto);

        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @Operation(summary = "하루방 일기 수정하기", description = "diary_id를 사용하여 일기를 수정한다.")
    @PatchMapping("/{id}")
    public ResponseEntity<DiaryResDto> updateDiary(@PathVariable Long id,
        @RequestBody DiaryReqDto requestDto) {
        DiaryResDto response = diaryService.updateDiary(id, requestDto);

        return ResponseEntity.ok(response);
    }

    @Operation(summary = "하루방 일기 단건 조회하기", description = "diary_id를 사용해 하나의 일기를 조회한다.")
    @GetMapping("/{id}")
    public ResponseEntity<DiaryResDto> getDiary(@PathVariable Long id) {
        DiaryResDto response = diaryService.getDiary(id);

        return ResponseEntity.ok(response);
    }

    @Operation(summary = "유저의 모든 일기 조회하기", description = "member_id를 사용하여 유저의 모든 일기를 조회한다.")
    @GetMapping("/by-member/{memberId}")
    public ResponseEntity<List<DiaryResDto>> getDiaryByMemberId(@PathVariable Long memberId) {
        List<DiaryResDto> response = diaryService.getDiaryListByMemberId(memberId);

        return ResponseEntity.ok(response);
    }

    @Operation(summary = "하루방 일기 삭제", description = "해당 diary_id를 삭제한다.")
    @DeleteMapping("/{id}")
    public ResponseEntity<DiaryResDto> deleteDiary(@PathVariable Long id) {
        diaryService.deleteDiary(id);

        return ResponseEntity.noContent().build();
    }
}
