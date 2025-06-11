package com.dolharubang.domain.event;

import java.time.LocalDate;

public record AnniversaryEvent(
    Long stoneId,
    Long memberId,
    LocalDate today,
    long daysSinceAdoption
) {

}

