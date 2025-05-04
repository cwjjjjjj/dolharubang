package com.dolharubang.service;

import com.dolharubang.domain.dto.request.MemberItemReqDto;
import com.dolharubang.domain.dto.response.memberItem.CustomItemResDto;
import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.MemberItem;
import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import com.dolharubang.mongo.entity.Item;
import com.dolharubang.mongo.enumTypes.ItemType;
import com.dolharubang.mongo.repository.ItemRepository;
import com.dolharubang.mongo.service.ItemService;
import com.dolharubang.repository.MemberItemRepository;
import com.dolharubang.repository.MemberRepository;
import java.util.List;
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
            item.getItemId().toString());
        if (exists) {
            throw new CustomException(ErrorCode.DUPLICATE_ITEM);
        }

        MemberItem memberItem = MemberItemReqDto.toEntity(memberItemReqDto, member);
        memberItemRepository.save(memberItem);
    }

    @Transactional
    public void initializeItems(Member member) {
        List<Item> items = itemRepository.findAll();

        for (Item item : items) {
            boolean isDefaultItem = "없음".equals(item.getItemName());

            MemberItem memberItem = MemberItem.builder()
                .member(member)
                .itemId(item.getItemId().toString())
                .whetherHasItem(isDefaultItem)
                .selected(isDefaultItem)
                .build();

            memberItemRepository.save(memberItem);
        }
    }

    //아이템 구매
    @Transactional
    public List<CustomItemResDto> updateItemOwnership(Long memberId, String itemId) {

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
                    .filter(mi -> mi.getItemId().equals(item.getItemId().toString()))
                    .findFirst()
                    .orElseThrow(() -> new CustomException(ErrorCode.MEMBERITEM_NOT_FOUND));

                return CustomItemResDto.fromEntity(memberItem, item);
            })
            .collect(Collectors.toList());
    }

    //착용 아이템 변경
    @Transactional
    public List<CustomItemResDto> wearItem(Long memberId, String itemId) {
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

    private MemberItem getMemberItem(String itemId, Member member) {
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
