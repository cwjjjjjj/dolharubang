package com.dolharubang.domain.dto.response;

import com.dolharubang.domain.entity.HasItem;
import com.dolharubang.mongo.enumTypes.ItemType;
import java.time.LocalDateTime;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Builder
@Getter
@Setter
@ToString
public class HasItemResDto {
    private Long hasItemId;
    private String itemId;
    private ItemType itemType;
    private LocalDateTime createdAt;
    private LocalDateTime modifiedAt;

    public static HasItemResDto fromEntity(HasItem hasItem) {
        return HasItemResDto.builder()
            .hasItemId(hasItem.getHasItemId())
            .itemId(hasItem.getItemId())
            .itemType(hasItem.getItemType())
            .createdAt(hasItem.getCreatedAt())
            .modifiedAt(hasItem.getModifiedAt())
            .build();
    }
}
