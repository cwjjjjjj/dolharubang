package com.dolharubang.domain.entity;

import com.dolharubang.type.Authority;
import com.dolharubang.type.Provider;
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

@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Entity
@Getter
public class Member extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long memberId;

    @Enumerated(EnumType.STRING)
    private Authority authority;

    @Enumerated(EnumType.STRING)
    private Provider provider;

    private String providerId;

    private String memberEmail;

    private String nickname;

    private String birthday;

    private int sands;

    private String profilePicture;

    private String spaceName;

    private int closeness;

    @Builder
    public Member(Long memberId, Authority authority, Provider provider, String providerId,
        String memberEmail, String nickname, String birthday,
        int sands, String profilePicture,
        String spaceName, int closeness) {
        this.memberId = memberId;
        this.authority = authority;
        this.provider = provider;
        this.providerId = providerId;
        this.memberEmail = memberEmail;
        this.nickname = nickname;
        this.birthday = birthday;
        this.sands = sands;
        this.profilePicture = profilePicture;
        this.spaceName = spaceName;
        this.closeness = closeness;
    }

    public void update(String nickname, String spaceName) {
        this.nickname = nickname;
        this.spaceName = spaceName;
        this.modifiedAt = LocalDateTime.now();
    }

    public void updateSpaceName(String spaceName) {
        this.spaceName = spaceName;
        this.modifiedAt = LocalDateTime.now();
    }

    public void addInfo(String nickname, String birthday) {
        this.nickname = nickname;
        this.birthday = birthday;
        this.modifiedAt = LocalDateTime.now();
    }

    public void decreaseSands(int price) {
        this.sands -= price;
    }

    public int increaseSands(int increasingAmount) {
        this.sands += increasingAmount;
        return this.sands;
    }

    public void increaseCloseness(int increasingAmount) {
        this.closeness += increasingAmount;
    }

    public void updateProfilePicture(String profilePicture) {
        this.profilePicture = profilePicture;
        this.modifiedAt = LocalDateTime.now();
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
}
