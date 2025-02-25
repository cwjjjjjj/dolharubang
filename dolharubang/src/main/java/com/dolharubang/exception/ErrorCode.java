package com.dolharubang.exception;

import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
public enum ErrorCode {

    // 스케줄 관련 오류
    SCHEDULE_NOT_FOUND(HttpStatus.NOT_FOUND, "해당 스케줄을 찾을 수 없습니다."),
    DUPLICATE_SCHEDULE(HttpStatus.CONFLICT, "중복된 스케줄이 존재합니다."),

    // 유저 관련 오류
    MEMBER_NOT_FOUND(HttpStatus.NOT_FOUND, "해당 유저를 찾을 수 없습니다."),

    // 하루방 관련 오류
    DIARY_NOT_FOUND(HttpStatus.NOT_FOUND, "해당 일기를 찾을 수 없습니다."),

    //돌 관련 오류
    STONE_NOT_FOUND(HttpStatus.NOT_FOUND, "돌을 찾을 수 없습니다."),
    SIGNTEXT_NOT_FOUND(HttpStatus.NOT_FOUND, "팻말 내용을 찾을 수 없습니다."),
    ABILITY_ALREADY_ACTIVATED(HttpStatus.CONFLICT,"이미 활성화된 능력입니다."),

    //돌 종류 관련 오류
    SPECIES_NOT_FOUND(HttpStatus.NOT_FOUND, "해당하는 돌 종류를 찾을 수 없습니다."),

    // 아이템 관련 오류
    MEMBERITEM_NOT_FOUND(HttpStatus.NOT_FOUND, "해당 멤버아이템을 찾을 수 없습니다."),
    ITEM_NOT_FOUND(HttpStatus.NOT_FOUND, "해당 아이템을 찾을 수 없습니다."),
    DUPLICATE_ITEM(HttpStatus.CONFLICT, "중복된 아이템이 존재합니다."),
    LACK_OF_SAND(HttpStatus.CONFLICT, "모래알이 부족합니다."),
    ALREADY_BOUGHT(HttpStatus.CONFLICT, "이미 구매한 아이템입니다."),

    // 입력값 관련 오류
    INVALID_INPUT_VALUE(HttpStatus.BAD_REQUEST, "유효하지 않은 입력값입니다."),
    INVALID_DATE_FORMAT(HttpStatus.BAD_REQUEST, "잘못된 날짜 형식입니다."),
    MISSING_REQUIRED_FIELD(HttpStatus.BAD_REQUEST, "필수 필드가 누락되었습니다."),

    // 권한 관련 오류
    UNAUTHORIZED(HttpStatus.UNAUTHORIZED, "인증에 실패하였습니다."),
    FORBIDDEN(HttpStatus.FORBIDDEN, "접근 권한이 없습니다."),

    // 서버 오류
    INTERNAL_SERVER_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "서버 내부 오류가 발생했습니다."),
    DATABASE_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "데이터베이스 오류가 발생했습니다."),

    // 인증 관련 오류
    AUTHENTICATION_FAILED(HttpStatus.UNAUTHORIZED, "인증에 실패하였습니다."),

    // Json 변환 에러
    JSON_CONVERSION_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "JSON 변환 과정에서 오류가 발생했습니다."),

    // 친구 관련 오류
    FRIEND_REQUEST_ALREADY_EXISTS(HttpStatus.CONFLICT, "이미 친구 요청을 보냈습니다."),
    FRIEND_NOT_FOUND(HttpStatus.NOT_FOUND, "해당 친구 요청을 찾을 수 없습니다."),
    FRIEND_CANNOT_BE_DELETED(HttpStatus.BAD_REQUEST, "친구를 삭제할 수 없습니다."),
    FRIEND_ALREADY_ACCEPTED(HttpStatus.BAD_REQUEST, "이미 친구 요청을 수락했습니다."),
    FRIEND_ALREADY_PENDING(HttpStatus.BAD_REQUEST, "이미 친구 요청을 보냈습니다."),
    FRIEND_ALREADY_DECLINED(HttpStatus.BAD_REQUEST, "이미 친구 요청을 거절했습니다."),

    // contest 관련 오류
    CONTEST_NOT_FOUND(HttpStatus.NOT_FOUND, "해당 돌 자랑을 찾을 수 없습니다."),
    CONTEST_NOT_FOUND_BY_MEMBER(HttpStatus.NOT_FOUND, "해당 멤버의 돌 자랑은 없습니다."),
    CONTEST_MEMBER_MISMATCH(HttpStatus.NOT_FOUND, "해당 멤버에게서 확인할 수 없는 돌자랑입니다."),

    // 미션 관련 오류
    MISSION_NOT_FOUND(HttpStatus.NOT_FOUND, "해당 미션을 찾을 수 없습니다."),
    DUPLICATE_MISSION(HttpStatus.CONFLICT, "중복된 미션이 존재합니다."),
    INVALID_MISSION_STATUS(HttpStatus.BAD_REQUEST, "유효하지 않은 미션 상태입니다."),

    // 멤버 미션 관련 오류
    DUPLICATE_MEMBER_MISSION(HttpStatus.CONFLICT, "해당 유저는 이미 해당 미션을 진행중이거나 완료했습니다."),
    MEMBER_MISSION_NOT_FOUND(HttpStatus.NOT_FOUND, "해당 유저에게서 이 미션을 찾을 수 없습니다."),
    MEMBER_MISSION_ALREADY_REWARDED(HttpStatus.CONFLICT, "이미 보상을 받은 미션입니다."),
    INVALID_MISSION_PROGRESS(HttpStatus.BAD_REQUEST, "잘못된 미션 진행도입니다."),

    // reward 관련 오류
    MISSING_ITEM_NUMBER(HttpStatus.BAD_REQUEST, "아이템 보상은 아이템 번호가 필요합니다."),
    INVALID_REWARD_QUANTITY(HttpStatus.BAD_REQUEST, "보상 수량은 0보다 커야 합니다."),

    INVALID_REWARD_CLAIM(HttpStatus.BAD_REQUEST, "보상을 받을 수 없는 상태입니다."),
    MISSION_NOT_COMPLETED(HttpStatus.BAD_REQUEST, "완료되지 않은 미션입니다."),
    ALREADY_REWARDED(HttpStatus.BAD_REQUEST, "이미 보상을 받았습니다."),
    INVALID_REWARD_TYPE(HttpStatus.BAD_REQUEST, "잘못된 보상 타입입니다."),
    ALREADY_HAVE_ITEM(HttpStatus.CONFLICT, "이미 보유하고 있는 아이템입니다.");

    private final HttpStatus httpStatus;
    private final String detail;

    ErrorCode(HttpStatus httpStatus, String detail) {
        this.httpStatus = httpStatus;
        this.detail = detail;
    }

}
