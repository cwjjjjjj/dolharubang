package com.dolharubang.domain.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@Builder
@Table(name = "contests")
@AllArgsConstructor
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Contest extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "contest_id")
    Long id;

    @ManyToOne
    @JoinColumn(name = "member_id")
    Member member;

    @Column(name = "is_public")
    Boolean isPublic;

    @Column(name = "profile_img_url")
    String profileImgUrl;

    @Column(name = "stone_name")
    String stoneName;

    public void updateImage(String profileImgUrl) {
        this.profileImgUrl = profileImgUrl;
    }

    public void updateContestVisibility(Boolean isPublic) {
        this.isPublic = isPublic;
    }
}
