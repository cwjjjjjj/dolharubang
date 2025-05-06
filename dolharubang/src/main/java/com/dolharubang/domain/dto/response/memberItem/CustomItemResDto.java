package com.dolharubang.domain.dto.response.memberItem;

import com.dolharubang.domain.entity.Item;
import com.dolharubang.domain.entity.MemberItem;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Builder;
import lombok.Getter;
import lombok.ToString;

@Builder
@Getter
@ToString
public class CustomItemResDto {

    @JsonProperty("name")
    private String itemName;
    @JsonProperty("isOwned")
    private boolean whetherHasItem;
    @JsonProperty("isSelected")
    private boolean selected;
    private int price;
    private String imageUrl;
    private Long itemId;

    public static CustomItemResDto fromEntity(MemberItem memberItem, Item item) {
        return CustomItemResDto.builder()
            .itemName(item.getItemName())
            .whetherHasItem(memberItem.isWhetherHasItem())
            .selected(memberItem.isSelected())
            .price(item.getPrice())
            .imageUrl(item.getImageUrl())
            .itemId(item.getItemId())
            .build();
    }
}
