package com.dolharubang.type;

public enum ConditionType {
    FIRST,          // 최초 1회
    CUMULATIVE,     // 누적
    CONTINUOUS,     // 연속
    SPECIFIC_EVENT  // 특정 조건 ㅇ(예: 특정 메뉴 추천받기, 친구 거절당하기 등)
}
