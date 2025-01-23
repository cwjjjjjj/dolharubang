package com.dolharubang.domain.dto.response.stone;

import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.Stone;
import com.dolharubang.mongo.enumTypes.ItemType;
import com.dolharubang.type.AbilityType;
import java.util.Map;
import lombok.Builder;
import lombok.Getter;
import lombok.ToString;

@Builder
@Getter
@ToString
public class StoneResDto {

    private Long stoneId;
    private Member member;
    private Long speciesId;
    private String stoneName;
    private Long closeness;
    private Map<AbilityType, Boolean> abilityAble;
    private String signText;
    private Map<ItemType, String> custom;

    public static StoneResDto fromEntity(Stone stone) {
        return StoneResDto.builder()
            .stoneId(stone.getStoneId())
            .speciesId(stone.getSpeciesId())
            .stoneName(stone.getStoneName())
            .closeness(stone.getCloseness())
            .abilityAble(stone.getAbilityAble())
            .signText(stone.getSignText())
            .custom(stone.getCustom())
            .build();
    }
}
