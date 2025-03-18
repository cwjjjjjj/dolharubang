package com.dolharubang.domain.dto.oauth;

import com.dolharubang.exception.ErrorCode;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.RequiredArgsConstructor;

/**
 * API 응답을 표준화하기 위한 클래스
 * @param <T> 응답 데이터의 타입
 */
@Getter
@RequiredArgsConstructor(access = AccessLevel.PRIVATE)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
public class ApiResponse<T> {

    private final int code;
    private final String message;
    private T data;

    // 자주 사용되는 에러 코드 상수 정의
    public static final ErrorCode UNAUTHORIZED_ERROR = ErrorCode.UNAUTHORIZED;
    public static final ErrorCode FORBIDDEN_ERROR = ErrorCode.FORBIDDEN;

    /**
     * 데이터 없이 성공 응답을 생성합니다.
     * @param status 성공 상태 코드
     * @return ApiResponse 객체
     * @param <T> 데이터 타입
     */
    public static <T> ApiResponse<T> onSuccess(SuccessStatus status) {
        return new ApiResponse<>(status.getCode(), status.getMessage());
    }

    /**
     * 데이터를 포함한 성공 응답을 생성합니다.
     * @param status 성공 상태 코드
     * @param data 응답에 포함할 데이터
     * @return ApiResponse 객체
     * @param <T> 데이터 타입
     */
    public static <T> ApiResponse<T> onSuccess(SuccessStatus status, T data) {
        return new ApiResponse<>(status.getCode(), status.getMessage(), data);
    }

    /**
     * 실패 응답을 생성합니다.
     * @param errorCode 에러 코드
     * @return ApiResponse 객체
     * @param <T> 데이터 타입
     */
    public static <T> ApiResponse<T> onFailure(ErrorCode errorCode) {
        return new ApiResponse<>(errorCode.getHttpStatus().value(), errorCode.getDetail());
    }

    /**
     * 커스텀 메시지가 포함된 실패 응답을 생성합니다.
     * @param errorCode 에러 코드
     * @param message 커스텀 에러 메시지
     * @return ApiResponse 객체
     * @param <T> 데이터 타입
     */
    public static <T> ApiResponse<T> onFailure(ErrorCode errorCode, String message) {
        return new ApiResponse<>(errorCode.getHttpStatus().value(), message);
    }
}