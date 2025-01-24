package com.dolharubang.domain.dto.response.stone;

import com.dolharubang.domain.entity.Species;
import com.dolharubang.domain.entity.Stone;
import com.dolharubang.type.AbilityType;
import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import lombok.Builder;
import lombok.Getter;
import lombok.ToString;

@Builder
@Getter
@ToString
public class StoneProfileResDto {

    @JsonProperty("dolBirth")
    private LocalDateTime createdAt;
    @JsonProperty("personality")
    private String characteristic;
    @JsonProperty("baseAbility")
    private AbilityType baseAbility;
    @JsonProperty("dolName")
    private String stoneName;
    @JsonProperty("friendShip")
    private Long closeness;
    @JsonProperty("activeAbility")
    private List<AbilityType> activeAbilities;
    @JsonProperty("potential")
    private List<AbilityType> potentialAbilities;

    public static StoneProfileResDto fromEntity(Stone stone, Species species) {
        List<AbilityType> activeAbilities = new ArrayList<>();
        List<AbilityType> potentialAbilities = new ArrayList<>();

        stone.getAbilityAble().forEach((ability, value) -> {
            if(ability != species.getBaseAbility()) {
                if (value)
                    activeAbilities.add(ability);
                else
                    potentialAbilities.add(ability);
            }
        });

        return StoneProfileResDto.builder()
            .createdAt(stone.getCreatedAt())
            .characteristic(species.getCharacteristic())
            .baseAbility(species.getBaseAbility())
            .stoneName(stone.getStoneName())
            .closeness(stone.getCloseness())
            .activeAbilities(activeAbilities)
            .potentialAbilities(potentialAbilities)
            .build();
    }
}
