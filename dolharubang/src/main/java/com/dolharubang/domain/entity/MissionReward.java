package com.dolharubang.domain.entity;

import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import com.dolharubang.type.RewardType;
import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Embeddable
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class MissionReward {

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private RewardType type;

    @Column(nullable = false)
    private int quantity;

    private String itemNo;


    @Builder
    public MissionReward(RewardType type, int quantity, String itemNo) {
        this.type = type;
        this.quantity = quantity;
        this.itemNo = itemNo;
        validate();
    }

    private void validate() {
        if (type == RewardType.ITEM) {
            if (itemNo == null || itemNo.isBlank()) {
                throw new CustomException(ErrorCode.MISSING_ITEM_NUMBER);
            }
            // 아이템 번호 형식이나 실제 존재하는 아이템인지 검증하는 로직
            if (!isValidItemNumber(itemNo)) {
                throw new CustomException(ErrorCode.ITEM_NOT_FOUND);
            }
        }
        if (quantity <= 0) {
            throw new CustomException(ErrorCode.INVALID_REWARD_QUANTITY);
        }
    }

    // 아이템 번호 유효성 검증 메서드
    private boolean isValidItemNumber(String itemNo) {
        // 아이템 번호 검증 로직
        // 예: 형식 검증, 실제 아이템 존재 여부 확인 등
        return true; // 임시 반환
    }
}
