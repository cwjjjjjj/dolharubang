package com.dolharubang.domain.dto.oauth;

import lombok.AccessLevel;
import lombok.Getter;
import lombok.RequiredArgsConstructor;

/**
 * API 성공 응답에 사용되는 상태 코드 상수 정의
 */
@Getter
@RequiredArgsConstructor(access = AccessLevel.PRIVATE)
public enum SuccessStatus {

    /**
     * 200 OK: 요청이 성공적으로 처리되었음
     */
    _OK(200, "요청이 성공적으로 처리되었습니다."),

    /**
     * 201 CREATED: 새로운 리소스가 성공적으로 생성됨
     */
    _CREATED(201, "리소스가 성공적으로 생성되었습니다."),

    /**
     * 204 NO_CONTENT: 요청은 성공했지만 컨텐츠는 없음
     */
    _NO_CONTENT(204, "요청은 성공했지만 컨텐츠가 없습니다.");

    private final int code;
    private final String message;
}