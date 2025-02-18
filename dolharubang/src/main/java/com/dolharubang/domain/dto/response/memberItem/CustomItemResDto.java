package com.dolharubang.domain.dto.response.memberItem;

import com.dolharubang.domain.entity.MemberItem;
import com.dolharubang.mongo.entity.Item;
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
    private boolean isSelected;
    private int price;
    private String imageUrl;
    private String itemId;

    public static CustomItemResDto fromEntity(MemberItem memberItem, Item item) {
        return CustomItemResDto.builder()
            .itemName(item.getItemName())
            .whetherHasItem(memberItem.isWhetherHasItem())
            .isSelected(memberItem.isSelected())
            .price(item.getPrice())
            .imageUrl(item.getImageUrl())
            .itemId(item.getItemId().toString())
            .build();
    }
}
