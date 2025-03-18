package com.dolharubang.domain.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import java.time.LocalDateTime;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Entity
@Getter
public class Diary extends BaseEntity{

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long diaryId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    private String contents;

    private String emoji;

    private String imageUrl;

    private String reply;

    @Builder
    public Diary(Member member, String contents, String emoji, String imageUrl, String reply) {
        this.member = member;
        this.contents = contents;
        this.emoji = emoji;
        this.imageUrl = imageUrl;
        this.reply = reply;
    }

    //엔티티가 영속성 컨텍스트에 저장되기 전에 호출
    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.modifiedAt = LocalDateTime.now();
    }

    //엔티티가 영속성 컨텍스트에 업데이트되기 전에 호출
    @PreUpdate
    protected void onUpdate() {
        this.modifiedAt = LocalDateTime.now();
    }

    public void update(Member member, String contents, String emoji, String imageUrl, String reply) {
        this.member = member;
        this.contents = contents;
        this.emoji = emoji;
        this.imageUrl = imageUrl;
        this.reply = reply;
    }

    public void updateImageUrl(String imageUrl) {
        this.imageUrl = imageUrl; // 이미지 URL 필드에 저장
    }
}
