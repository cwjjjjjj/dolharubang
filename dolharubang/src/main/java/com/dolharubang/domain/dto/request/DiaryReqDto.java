package com.dolharubang.domain.dto.request;

import com.dolharubang.domain.entity.Diary;
import com.dolharubang.domain.entity.Member;
import lombok.Getter;

@Getter
public class DiaryReqDto {

    private Long memberId;
    private String contents;
    private String emoji;
    private String image;
    private String reply;

    public static Diary toEntity(DiaryReqDto dto, Member member) {
        return Diary.builder()
            .member(member)
            .contents(dto.getContents())
            .emoji(dto.getEmoji())
            .image(dto.getImage())
            .reply(dto.getReply())
            .build();
    }
}
