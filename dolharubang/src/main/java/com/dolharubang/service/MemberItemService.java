package com.dolharubang.service;

import com.dolharubang.domain.dto.request.MemberItemReqDto;
import com.dolharubang.domain.dto.response.memberItem.CustomItemResDto;
import com.dolharubang.domain.dto.response.memberItem.MemberItemResDto;
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

    public MemberItemService(MemberItemRepository memberItemRepository, MemberRepository memberRepository,
        ItemRepository itemRepository, ItemService itemService) {
        this.memberItemRepository = memberItemRepository;
        this.memberRepository = memberRepository;
        this.itemRepository = itemRepository;
        this.itemService = itemService;
    }

    // TODO createMember에 넣기
    @Transactional
    public MemberItemResDto createMemberItem(MemberItemReqDto memberItemReqDto) {
        Member member = memberRepository.findById(memberItemReqDto.getMemberId())
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        //멤버를 잘 찾았다면
        Item item = itemRepository.findByItemId(memberItemReqDto.getItemId());

        //아이템도 잘 찾았다면
        boolean exists = memberItemRepository.existsByMemberAndItemId(member, item.getItemId().toString());
        if(exists) {
            throw new CustomException(ErrorCode.DUPLICATE_ITEM);
        }

        MemberItem memberItem = MemberItemReqDto.toEntity(memberItemReqDto, member);
        MemberItem savedMemberItem = memberItemRepository.save(memberItem);
        return MemberItemResDto.fromEntity(savedMemberItem);
    }

    //아이템 구매
    @Transactional
    public MemberItemResDto updateItemOwnership(Long memberId, String itemId) {

        Member member = memberRepository.findById(memberId)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        MemberItem memberItem = memberItemRepository.findByMemberAndItemId(member, itemId)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBERITEM_NOT_FOUND));

        Item item = itemService.findByItemId(memberItem.getItemId());

        if(memberItem.isWhetherHasItem()) {
            throw new CustomException(ErrorCode.ALREADY_BOUGHT);
        }

        if(member.getSands() < item.getPrice()) {
            throw new CustomException(ErrorCode.LACK_OF_SAND);
        }

        member.deductSands(item.getPrice());
        memberItem.updateWhetherHasItem();
        memberRepository.save(member);

        return MemberItemResDto.fromEntity(memberItem);
    }

    //카테고리별 조회
    @Transactional(readOnly = true)
    public List<CustomItemResDto> findItemsByType(Long memberId, ItemType itemType) {
        Member member = memberRepository.findById(memberId)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

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
    /*
    보유했으면서 착용하지 않은 아이템인 경우
     */


    /*
    보유하지 않은 아이템인 경우
     */

}
