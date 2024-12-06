package com.dolharubang.domain.dto.response;

import com.dolharubang.domain.entity.Diary;
import java.time.LocalDateTime;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Builder
@Getter
@Setter
@ToString
public class DiaryResDto {

    private Long diaryId;
    private String contents;
    private String emoji;
    private String imageUrl;
    private String reply;
    private LocalDateTime createdAt;
    private LocalDateTime modifiedAt;

    public static DiaryResDto fromEntity(Diary diary) {
        return DiaryResDto.builder()
            .diaryId(diary.getDiaryId())
            .contents(diary.getContents())
            .emoji(diary.getEmoji())
            .imageUrl(diary.getImageUrl())
            .reply(diary.getReply())
            .createdAt(diary.getCreatedAt())
            .modifiedAt(diary.getModifiedAt())
            .build();
    }
}
