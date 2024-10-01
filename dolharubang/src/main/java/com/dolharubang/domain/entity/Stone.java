package com.dolharubang.domain.entity;

import com.dolharubang.mongo.enumTypes.ItemType;
import com.dolharubang.type.AbilityType;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.util.Map;
import lombok.Getter;
import lombok.NoArgsConstructor;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.MapKeyEnumerated;
import jakarta.persistence.CollectionTable;

@NoArgsConstructor
@Entity
@Table(name = "stones")
@Getter
public class Stone {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long stoneId;

    @ManyToOne
    @JoinColumn(name = "member_id")
    private Member member;

    private Long speciesId;

    private String stoneName;

    private Long closeness;

    @ElementCollection
    @CollectionTable(name = "stone_ability_able", joinColumns = @JoinColumn(name = "stone_id"))
    @MapKeyEnumerated  // 또는 @MapKeyColumn을 사용하여 key의 타입에 따라 설정
    private Map<AbilityType, Boolean> abilityAble;

    private String signText;

    @ElementCollection
    @CollectionTable(name = "stone_custom", joinColumns = @JoinColumn(name = "stone_id"))
    @MapKeyEnumerated  // 또는 @MapKeyColumn을 사용하여 key의 타입에 따라 설정
    private Map<ItemType, String> custom;
}
