package com.dolharubang.domain.dto.request;

import com.dolharubang.domain.entity.Diary;
import lombok.Getter;

@Getter
public class DiaryReqDto {

    private String contents;
    private String emoji;
    private String imageBase64;

    public static Diary toEntity(DiaryReqDto dto) {
        return Diary.builder()
            .contents(dto.getContents())
            .emoji(dto.getEmoji())
            .build();
    }
}
