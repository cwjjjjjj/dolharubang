package com.dolharubang.domain.dto.response.stone;

import com.dolharubang.domain.entity.Stone;
import com.dolharubang.type.AbilityType;
import java.util.Map;
import lombok.Builder;
import lombok.Getter;
import lombok.ToString;

@Builder
@Getter
@ToString
public class StneProfileResDto {

    //dolBirth
    private Long speciesId;
    //species로부터
    //personality
    //baseAbility 를 가져와서 반환
    private String stoneName;
    //dolName
    //friendShip
    private Long closeness;
    //activeAbility
    //potential
    private Map<AbilityType, Boolean> abilityAble;

    public static StneProfileResDto fromEntity(Stone stone) {
        return StneProfileResDto.builder()
            .speciesId(stone.getSpeciesId())
            .stoneName(stone.getStoneName())
            .closeness(stone.getCloseness())
            .abilityAble(stone.getAbilityAble())
            .build();
    }
}
