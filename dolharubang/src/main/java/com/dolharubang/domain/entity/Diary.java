package com.dolharubang.domain.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Entity
@Table(name = "diaries")
@Getter
public class Diary extends BaseEntity{

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long diaryId;

    @ManyToOne
    @JoinColumn(name = "member_id")
    private Member member;

    private String contents;

    private String emoji;

    private String image;

    private String reply;

    @Builder
    public Diary(Member member, String contents, String emoji, String image, String reply,
        LocalDateTime createdAt, LocalDateTime modifiedAt) {
        this.member = member;
        this.contents = contents;
        this.emoji = emoji;
        this.image = image;
        this.reply = reply;
    }

    public void update(Member member, String contents, String emoji, String image, String response) {
        this.member = member;
        this.contents = contents;
        this.emoji = emoji;
        this.image = image;
        this.reply = response;
    }
}
