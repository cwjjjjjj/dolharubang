package com.dolharubang.domain.dto.request;

import com.dolharubang.domain.entity.Species;
import com.dolharubang.type.AbilityType;
import lombok.Getter;

@Getter
public class SpeciesReqDto {

    private String speciesName;
    private String characteristic;
    private AbilityType baseAbility;

    public static Species toEntity(SpeciesReqDto speciesReqDto) {
        return Species.builder()
            .speciesName(speciesReqDto.speciesName)
            .characteristic(speciesReqDto.characteristic)
            .baseAbility(speciesReqDto.baseAbility)
            .build();
    }
}
