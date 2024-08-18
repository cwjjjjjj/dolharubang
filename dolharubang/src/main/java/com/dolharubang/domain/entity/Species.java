package com.dolharubang.domain.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor
public class Species {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "species_id")
    private Long id;

    private String speciesName;

    private String characteristic;

    private String appearanceUrl;

    private String base_ability;

    @Builder
    public Species(Long id, String speciesName, String characteristic, String appearanceUrl,
        String base_ability) {
        this.id = id;
        this.speciesName = speciesName;
        this.characteristic = characteristic;
        this.appearanceUrl = appearanceUrl;
        this.base_ability = base_ability;
    }

    //새로 추가되거나 수정될 예정이 없음
}
