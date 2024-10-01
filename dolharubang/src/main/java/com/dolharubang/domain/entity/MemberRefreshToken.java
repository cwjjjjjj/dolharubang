package com.dolharubang.domain.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@NoArgsConstructor
@Entity
@Table(name = "member_refresh_tokens")
@Getter
public class MemberRefreshToken {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long refreshTokenId;

    @ManyToOne
    @JoinColumn(name = "member_id")
    private Member member;

    private String refreshToken;

    @Builder
    public MemberRefreshToken(Member member, String refreshToken) {
        this.member = member;
        this.refreshToken = refreshToken;
    }
}
