package com.dolharubang.domain.dto.request;

import com.dolharubang.domain.entity.Stone;
import lombok.Getter;

@Getter
public class StoneReqDto {

    private Long speciesId;
    private String stoneName;
    private Long closeness;
    private String signText;

    public static Stone toEntity(StoneReqDto dto) {
        return Stone.builder()
            .speciesId(dto.getSpeciesId())
            .stoneName(dto.getStoneName())
            .closeness(dto.getCloseness())
            .signText(dto.getSignText())
            .build();
    }
}
