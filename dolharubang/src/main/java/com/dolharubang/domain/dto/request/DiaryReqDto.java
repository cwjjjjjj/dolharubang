package com.dolharubang.domain.dto.request;

import com.dolharubang.domain.entity.Diary;
import com.dolharubang.domain.entity.Member;
import lombok.Getter;

@Getter
public class DiaryReqDto {

    private Long memberId;
    private String contents;
    private String emoji;
    private String reply;
    private String imageBase64;

    public static Diary toEntity(DiaryReqDto dto, Member member) {
        return Diary.builder()
            .member(member)
            .contents(dto.getContents())
            .emoji(dto.getEmoji())
            .reply(dto.getReply())
            .build();
    }
}
