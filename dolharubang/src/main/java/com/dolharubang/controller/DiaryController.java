package com.dolharubang.controller;

import com.dolharubang.domain.dto.request.DiaryReqDto;
import com.dolharubang.domain.dto.response.DiaryResDto;
import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.oauth.PrincipalDetails;
import com.dolharubang.service.DiaryService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;
import java.util.Map;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

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
    public ResponseEntity<?> createDiary(
        @AuthenticationPrincipal PrincipalDetails principal, @RequestBody DiaryReqDto requestDto) {
        if (principal == null) {
            return ResponseEntity
                .status(HttpStatus.UNAUTHORIZED)
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of(
                    "code", "UNAUTHORIZED",
                    "message", "인증에 실패햐였습니다"
                ));
        }

        Member member = principal.getMember();
        DiaryResDto response = diaryService.createDiary(member, requestDto);

        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

//    @Operation(summary = "하루방 일기 수정하기", description = "diary_id를 사용하여 일기를 수정한다.")
//    @PatchMapping("/{id}")
//    public ResponseEntity<DiaryResDto> updateDiary(@PathVariable Long id,
//        @RequestBody DiaryReqDto requestDto) {
//        DiaryResDto response = diaryService.updateDiary(id, requestDto);
//
//        return ResponseEntity.ok(response);
//    }

    @Operation(summary = "하루방 일기 단건 조회하기", description = "diary_id를 사용해 하나의 일기를 조회한다.")
    @GetMapping("/{id}")
    public ResponseEntity<DiaryResDto> getDiary(@PathVariable Long id) {
        DiaryResDto response = diaryService.getDiary(id);

        return ResponseEntity.ok(response);
    }

    @Operation(summary = "유저의 모든 일기 조회하기", description = "헤더 토큰 기반으로 유저의 모든 일기를 조회한다.")
    @GetMapping("/list")
    public ResponseEntity<?> getDiaryByMemberId(
        @AuthenticationPrincipal PrincipalDetails principal) {

        if (principal == null) {
            return ResponseEntity
                .status(HttpStatus.UNAUTHORIZED)
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of(
                    "code", "UNAUTHORIZED",
                    "message", "인증에 실패햐였습니다"
                ));
        }

        Long memberId = findMemberId(principal);
        List<DiaryResDto> response = diaryService.getDiaryListByMemberId(memberId);

        return ResponseEntity.ok(response);
    }

    @Operation(summary = "하루방 일기 삭제", description = "해당 diary_id를 삭제한다.")
    @DeleteMapping("/{id}")
    public ResponseEntity<DiaryResDto> deleteDiary(@PathVariable Long id) {
        diaryService.deleteDiary(id);

        return ResponseEntity.noContent().build();
    }

    private static Long findMemberId(PrincipalDetails principal) {
        if (principal == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED);
        }

        Long memberId = principal.getMember().getMemberId();
        return memberId;
    }
}
