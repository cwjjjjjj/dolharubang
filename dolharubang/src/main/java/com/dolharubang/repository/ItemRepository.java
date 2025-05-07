package com.dolharubang.repository;

import com.dolharubang.domain.entity.Item;
import com.dolharubang.type.ItemType;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ItemRepository  extends JpaRepository<Item, Long>  {

    Item findByItemId(Long itemId);

    List<Item> findByItemType(ItemType itemType);

    List<Item> findByItemName(String itemName);

}
