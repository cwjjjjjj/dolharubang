package com.dolharubang.domain.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import lombok.Getter;
import lombok.NoArgsConstructor;

@NoArgsConstructor
@Entity
@Getter
public class Clover extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long cloverId;

    @JoinColumn( )
    private Long sendingMemberId;

    private Long receivingMemberId;

    private boolean isReplied;

    //createdAt이 보낸 시간
    //modifiedAt이 답장 시간
}
