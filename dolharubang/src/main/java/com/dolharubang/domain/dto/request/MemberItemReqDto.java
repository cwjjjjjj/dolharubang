package com.dolharubang.domain.dto.request;

import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.MemberItem;
import lombok.Getter;

@Getter
public class MemberItemReqDto {

    private Long memberId;
    private String itemId;
    private boolean whetherHasItem;

    public static MemberItem toEntity(MemberItemReqDto dto, Member member) {
        return MemberItem.builder()
            .member(member)
            .itemId(dto.getItemId())
            .whetherHasItem(dto.isWhetherHasItem())
            .build();
    }
}
