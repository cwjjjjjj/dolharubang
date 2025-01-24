package com.dolharubang.domain.dto.response;

import com.dolharubang.domain.entity.Species;
import com.dolharubang.type.AbilityType;
import lombok.Builder;
import lombok.Getter;
import lombok.ToString;

@Builder
@Getter
@ToString
public class SpeciesResDto {

    private Long speciesId;
    private String speciesName;
    private String characteristic;
    private AbilityType baseAbility;

    public static SpeciesResDto fromEntity(Species species) {
        return SpeciesResDto.builder()
            .speciesId(species.getSpeciesId())
            .speciesName(species.getSpeciesName())
            .characteristic(species.getCharacteristic())
            .baseAbility(species.getBaseAbility())
            .build();
    }
}
