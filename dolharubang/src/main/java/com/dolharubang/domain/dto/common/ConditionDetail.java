package com.dolharubang.domain.dto.common;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ConditionDetail {

    @JsonProperty("type")
    private String type;

    @JsonProperty("target")
    private String target;

    @JsonProperty("value")
    private int value;

    @JsonProperty("details")
    private Details details;
}
