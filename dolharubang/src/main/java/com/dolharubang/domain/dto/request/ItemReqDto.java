package com.dolharubang.domain.dto.request;

import com.dolharubang.domain.entity.Item;
import com.dolharubang.type.ItemType;
import lombok.Getter;

@Getter
public class ItemReqDto {

    private ItemType itemType;
    private String itemName;
    private String imageUrl;
    private int price;

    public static Item toEntity(ItemReqDto itemReqDto) {
        return Item.builder()
            .itemType(itemReqDto.itemType)
            .itemName(itemReqDto.itemName)
            .imageUrl(itemReqDto.imageUrl)
            .price(itemReqDto.price)
            .build();
    }
}
