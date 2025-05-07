package com.dolharubang.service;

import com.dolharubang.domain.dto.request.MemberItemReqDto;
import com.dolharubang.domain.dto.response.memberItem.CustomItemResDto;
import com.dolharubang.domain.entity.Item;
import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.MemberItem;
import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import com.dolharubang.repository.ItemRepository;
import com.dolharubang.repository.MemberItemRepository;
import com.dolharubang.repository.MemberRepository;
import com.dolharubang.type.ItemType;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
public class MemberItemService {

    private final MemberItemRepository memberItemRepository;
    private final MemberRepository memberRepository;
    private final ItemRepository itemRepository;
    private final ItemService itemService;

    public MemberItemService(MemberItemRepository memberItemRepository,
        MemberRepository memberRepository,
        ItemRepository itemRepository, ItemService itemService) {
        this.memberItemRepository = memberItemRepository;
        this.memberRepository = memberRepository;
        this.itemRepository = itemRepository;
        this.itemService = itemService;
    }

    // TODO createItem에 넣기
    @Transactional
    public void createMemberItem(MemberItemReqDto memberItemReqDto) {
        Member member = getMember(memberItemReqDto.getMemberId());
        Item item = itemRepository.findByItemId(memberItemReqDto.getItemId());

        boolean exists = memberItemRepository.existsByMemberAndItemId(member,
            item.getItemId());
        if (exists) {
            throw new CustomException(ErrorCode.DUPLICATE_ITEM);
        }

        MemberItem memberItem = MemberItemReqDto.toEntity(memberItemReqDto, member);
        memberItemRepository.save(memberItem);
    }

    @Transactional
    public void initializeItems(Member member) {
        List<Item> items = itemRepository.findAll();
        log.info("멤버 {} 아이템 초기화 시작, 총 아이템 수: {}", member.getMemberId(), items.size());

        // 타입별로 기본 아이템 ID를 저장할 맵
        Map<ItemType, Long> defaultItemsByType = new HashMap<>();

        for (Item item : items) {
            if (item.getItemName().equals("없음")) {
                defaultItemsByType.put(item.getItemType(), item.getItemId());
                log.info("기본 아이템 발견: {}, ID: {}, 타입: {}",
                    item.getItemName(), item.getItemId(), item.getItemType());
            }
        }

        for (Item item : items) {
            boolean isDefaultItem = defaultItemsByType.containsValue(item.getItemId());

            if (item.getItemType() == ItemType.SHAPE || item.getItemType() == ItemType.FACE) {
                isDefaultItem = false;
            }

            MemberItem memberItem = MemberItem.builder()
                .member(member)
                .itemId(item.getItemId())
                .whetherHasItem(isDefaultItem)
                .selected(isDefaultItem)
                .build();

            MemberItem savedItem = memberItemRepository.save(memberItem);

            if (isDefaultItem) {
                log.info("기본 아이템 저장 결과: ID={}, 보유={}, 착용={}",
                    savedItem.getItemId(), savedItem.isWhetherHasItem(), savedItem.isSelected());
            }
        }

        List<MemberItem> savedItems = memberItemRepository.findAllByMember(member);
        long defaultItemsCount = savedItems.stream()
            .filter(MemberItem::isWhetherHasItem)
            .filter(MemberItem::isSelected)
            .count();

        log.info("저장된 기본 아이템 수: {}", defaultItemsCount);
    }

    //아이템 구매
    @Transactional
    public List<CustomItemResDto> updateItemOwnership(Long memberId, Long itemId) {

        Member member = getMember(memberId);
        MemberItem memberItem = getMemberItem(itemId, member);
        Item item = itemService.findByItemId(memberItem.getItemId());

        if (memberItem.isWhetherHasItem()) {
            throw new CustomException(ErrorCode.ALREADY_BOUGHT);
        }

        if (member.getSands() < item.getPrice()) {
            throw new CustomException(ErrorCode.LACK_OF_SAND);
        }

        member.decreaseSands(item.getPrice());
        memberItem.buyItem();
        memberRepository.save(member);

        ItemType itemType = item.getItemType();
        return findCustomsByType(memberId, itemType);
    }

    //카테고리별 조회
    @Transactional(readOnly = true)
    public List<CustomItemResDto> findCustomsByType(Long memberId, ItemType itemType) {
        Member member = getMember(memberId);

        List<Item> items = itemRepository.findByItemType(itemType);
        List<MemberItem> memberItems = memberItemRepository.findAllByMember(member);

        return items.stream()
            .map(item -> {
                MemberItem memberItem = memberItems.stream()
                    .filter(mi -> mi.getItemId().equals(item.getItemId()))
                    .findFirst()
                    .orElseThrow(() -> new CustomException(ErrorCode.MEMBERITEM_NOT_FOUND));

                return CustomItemResDto.fromEntity(memberItem, item);
            })
            .collect(Collectors.toList());
    }

    //착용 아이템 변경
    @Transactional
    public List<CustomItemResDto> wearItem(Long memberId, Long itemId) {
        Member member = getMember(memberId);
        MemberItem targetMemberItem = getMemberItem(itemId, member);

        if (targetMemberItem.isSelected()) {
            Item targetItem = itemService.findByItemId(itemId);
            return findCustomsByType(memberId, targetItem.getItemType());
        }

        if (!targetMemberItem.isWhetherHasItem()) {
            updateItemOwnership(memberId, itemId);
        }

        Item targetItem = itemService.findByItemId(itemId);
        ItemType itemType = targetItem.getItemType();

        List<MemberItem> memberItems = memberItemRepository.findAllByMember(member);

        // 같은 타입의 모든 아이템 착용 해제
        memberItems.stream()
            .filter(memberItem -> {
                Item item = itemService.findByItemId(memberItem.getItemId());
                return item.getItemType() == itemType;
            })
            .forEach(memberItem -> memberItem.wearItem(false));

        targetMemberItem.wearItem(true);

        return findCustomsByType(memberId, itemType);
    }

    @Transactional
    public void updateSpeciesItemStatus(Member member, String speciesName) {
        List<MemberItem> memberItems = findAllItemsByMember(member);
        List<Item> speciesItems = itemRepository.findByItemName(speciesName);

        if (speciesItems.isEmpty()) {
            log.warn("No items found with name matching species: {}", speciesName);
            return;
        }

        // 종족 아이템의 타입별로 그룹화
        Map<ItemType, Item> speciesItemsByType = new HashMap<>();
        for (Item item : speciesItems) {
            speciesItemsByType.put(item.getItemType(), item);
        }

        // 각 타입별로 처리
        for (Map.Entry<ItemType, Item> entry : speciesItemsByType.entrySet()) {
            ItemType itemType = entry.getKey();
            Item speciesItem = entry.getValue();

            // 같은 타입의 모든 아이템 착용 해제
            memberItems.stream()
                .filter(memberItem -> {
                    Item item = itemService.findByItemId(memberItem.getItemId());
                    return item.getItemType() == itemType;
                })
                .forEach(memberItem -> memberItem.wearItem(false));

            // 종족 아이템 보유 및 착용
            Optional<MemberItem> memberItemOpt = memberItems.stream()
                .filter(mi -> mi.getItemId().equals(speciesItem.getItemId()))
                .findFirst();

            if (memberItemOpt.isPresent()) {
                MemberItem memberItem = memberItemOpt.get();
                memberItem.buyItem();
                memberItem.wearItem(true);
            } else {
                log.warn("MemberItem not found for itemId: {}, member: {}", speciesItem.getItemId(), member.getMemberId());
            }
        }
    }


    @Transactional(readOnly = true)
    public List<MemberItem> findAllItemsByMember(Member member) {
        return memberItemRepository.findAllByMember(member);
    }

    private MemberItem getMemberItem(Long itemId, Member member) {
        MemberItem memberItem = memberItemRepository.findByMemberAndItemId(member, itemId)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBERITEM_NOT_FOUND));
        return memberItem;
    }

    private Member getMember(Long memberId) {
        Member member = memberRepository.findById(memberId)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));
        return member;
    }
}
