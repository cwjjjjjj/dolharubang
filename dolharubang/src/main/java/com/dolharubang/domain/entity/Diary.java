package com.dolharubang.domain.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import lombok.AccessLevel;
import lombok.Data;
import lombok.NoArgsConstructor;

@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Entity
@Table(name = "diaries")
@Data
public class Diary {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long diaryId;

    private long memberId;

    private String contents;

    private String emoji;

    private String image;

    private String response;

    private LocalDateTime createdAt;

}
