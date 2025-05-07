package com.dolharubang.domain.dto.response;

import com.dolharubang.domain.entity.Item;
import com.dolharubang.type.ItemType;
import java.time.LocalDateTime;
import lombok.Builder;
import lombok.Getter;
import lombok.ToString;

@Builder
@Getter
@ToString
public class ItemResDto {

    private Long itemId;
    private ItemType itemType;
    private String itemName;
    private String imageUrl;
    private int price;
    private LocalDateTime createdAt;
    private LocalDateTime modifiedAt;

    public static ItemResDto fromEntity(Item item) {
        return ItemResDto.builder()
            .itemId(item.getItemId())
            .itemType(item.getItemType())
            .itemName(item.getItemName())
            .imageUrl(item.getImageUrl())
            .price(item.getPrice())
            .createdAt(item.getCreatedAt())
            .modifiedAt(item.getModifiedAt())
            .build();
    }
}
