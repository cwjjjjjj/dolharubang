package com.dolharubang.domain.entity;

import java.util.Map;
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
public class ConditionDetails {

    private String specificEvent;
    private Map<String, Object> additionalInfo;

    public boolean matchesSpecificEvent(String eventType) {
        return specificEvent != null && specificEvent.equals(eventType);
    }
}
