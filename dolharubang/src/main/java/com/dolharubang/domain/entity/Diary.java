package com.dolharubang.domain.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Entity
@Table(name = "diaries")
@Data
public class Diary {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long diaryId;

    private Long memberId;

    private String contents;

    private String emoji;

    private String image;

    private String response;

    private LocalDateTime createdAt;

    private LocalDateTime modifiedAt;

    @Builder
    public Diary(Long memberId, String contents, String emoji, String image, String response,
        LocalDateTime createdAt, LocalDateTime modifiedAt) {
        this.memberId = memberId;
        this.contents = contents;
        this.emoji = emoji;
        this.image = image;
        this.response = response;
        this.createdAt = createdAt;
        this.modifiedAt = modifiedAt;
    }

    public void update(String contents, String emoji, String image, String response) {
        this.contents = contents;
        this.emoji = emoji;
        this.image = image;
        this.response = response;
    }

    @PrePersist
    public void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.modifiedAt = LocalDateTime.now();
    }

    @PreUpdate
    public void onUpdate() {
        this.modifiedAt = LocalDateTime.now();
    }
}
