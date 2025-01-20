package com.dolharubang.domain.dto.request;

import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.Stone;
import com.dolharubang.mongo.enumTypes.ItemType;
import com.dolharubang.type.AbilityType;
import java.util.Map;
import lombok.Getter;

@Getter
public class StoneReqDto {

    private Long memberId;
    private Long speciesId;
    private String stoneName;
    private Long closeness;
    private Map<AbilityType, Boolean> abilityAble;
    private String signText;
    private Map<ItemType, String> custom;

    public static Stone toEntity(Member member, StoneReqDto dto) {
        return Stone.builder()
            .member(member)
            .speciesId(dto.getSpeciesId())
            .stoneName(dto.getStoneName())
            .closeness(dto.getCloseness())
            .abilityAble(dto.getAbilityAble())
            .signText(dto.getSignText())
            .custom(dto.getCustom())
            .build();
    }
}
