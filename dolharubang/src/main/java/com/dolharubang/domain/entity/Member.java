package com.dolharubang.domain.entity;

import com.dolharubang.type.SocialType;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import java.time.LocalDateTime;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.ColumnDefault;

@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Entity
@Getter
public class Member extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long memberId;

    @Enumerated(value = EnumType.STRING)
    private SocialType socialType;

    private String socialId;

    private String refreshToken;

    private String memberEmail;

    private String nickname;

    //TODO birthStone 필요함
    private String birthday;

    @ColumnDefault("0")
    private Long sands;

    private LocalDateTime lastLoginAt;

    @ColumnDefault("0")
    private Long totalLoginDays;

    private String profilePicture;

    private String spaceName;

    @Builder
    public Member(SocialType socialType, String socialId, String memberEmail,
        String nickname, String birthday, Long sands, LocalDateTime lastLoginAt,
        Long totalLoginDays, String profilePicture, String spaceName) {
        this.socialType = socialType;
        this.socialId = socialId;
        this.memberEmail = memberEmail;
        this.nickname = nickname;
        this.birthday = birthday;
        this.sands = sands;
        this.lastLoginAt = lastLoginAt;
        this.totalLoginDays = totalLoginDays;
        this.profilePicture = profilePicture;
        this.spaceName = spaceName;
    }

    //로그인 일수 증가
    public void incrementTotalLoginDays(Long totalLoginDays) {
        this.totalLoginDays = totalLoginDays + 1;
    }

    // 마지막 로그인 시간 업데이트
    public void updateLastLoginAt() {
        this.lastLoginAt = LocalDateTime.now();
    }

    public void updateRefreshToken(String refreshToken) {
        this.refreshToken = refreshToken;
    }

    public void resetRefreshToken() {
        this.refreshToken = null;
    }

    public void update(String nickname, String profilePicture, String spaceName) {
        this.nickname = nickname;
        this.profilePicture = profilePicture;
        this.spaceName = spaceName;
        this.modifiedAt = LocalDateTime.now();
    }

    public void deductSands(Long price) {
        this.sands -= price;
    }

    //엔티티가 영속성 컨텍스트에 저장되기 전에 호출
    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.lastLoginAt = LocalDateTime.now();
        this.modifiedAt = LocalDateTime.now();
    }

    //엔티티가 영속성 컨텍스트에 업데이트되기 전에 호출
    @PreUpdate
    protected void onUpdate() {
        this.modifiedAt = LocalDateTime.now();
    }
}
