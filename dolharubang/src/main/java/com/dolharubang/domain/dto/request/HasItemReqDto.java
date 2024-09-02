package com.dolharubang.domain.dto.request;

import com.dolharubang.domain.entity.HasItem;
import com.dolharubang.domain.entity.Member;
import com.dolharubang.mongo.enumTypes.ItemType;
import lombok.Getter;

@Getter
public class HasItemReqDto {

    private Long memberId;
    private String itemId;
    private ItemType itemType;

    public static HasItem toEntity(HasItemReqDto dto, Member member) {
        return HasItem.builder()
            .member(member)
            .itemId(dto.getItemId())
            .itemType(dto.getItemType())
            .build();
    }
}
