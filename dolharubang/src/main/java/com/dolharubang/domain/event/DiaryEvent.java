package com.dolharubang.domain.event;

import java.time.LocalDate;

public record DiaryEvent(Long memberId, LocalDate date) {

}

