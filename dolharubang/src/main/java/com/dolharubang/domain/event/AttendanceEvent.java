package com.dolharubang.domain.event;

import java.time.LocalDate;

public record AttendanceEvent(Long memberId, LocalDate date) {

}
