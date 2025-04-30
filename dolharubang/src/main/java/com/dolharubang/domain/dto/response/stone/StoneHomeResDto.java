package com.dolharubang.domain.dto.response.stone;

import com.dolharubang.domain.entity.Stone;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Builder;
import lombok.Getter;
import lombok.ToString;

@Builder
@Getter
@ToString
public class StoneHomeResDto {

    @JsonProperty("dolName")
    private String stoneName;
    @JsonProperty("friendShip")
    private Long closeness;
    private int mailCount;

    public static StoneHomeResDto fromEntity(Stone stone) {
        return StoneHomeResDto.builder()
            .stoneName(stone.getStoneName())
            .closeness(stone.getCloseness())
            .mailCount(7)
            .build();
    }

}
