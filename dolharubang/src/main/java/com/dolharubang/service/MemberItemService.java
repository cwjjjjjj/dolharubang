package com.dolharubang.service;

import com.dolharubang.domain.dto.request.MemberItemReqDto;
import com.dolharubang.domain.dto.response.memberItem.MemberItemResDto;
import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.MemberItem;
import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import com.dolharubang.mongo.entity.Item;
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

    // TODO 새로운 아이템이 추가될 경우 모든 멤버에 대해 실행해야 하는 메서드
    @Transactional
    public MemberItemResDto createMemberItem(MemberItemReqDto memberItemReqDto) {
        Member member = memberRepository.findById(memberItemReqDto.getMemberId())
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        //멤버를 잘 찾았다면
        Item item = itemRepository.findByItemId(memberItemReqDto.getItemId())
            .orElseThrow(() -> new CustomException(ErrorCode.ITEM_NOT_FOUND));

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

        Item item = itemService.findByItemId(memberItem.getItemId())
            .orElseThrow(() -> new CustomException(ErrorCode.ITEM_NOT_FOUND));

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

    //착용 아이템 변경

    /*
    현재상태, 구매, 착용 반환 타입
    1. 아이템 구매/변경
    2. 해당 아이템의 카테고리 확인
    3. 카테고리 아이템 List 반환
    - 해당하는 아이템 카테고리 -> 그 카테고리의 아이템 list 로직 구현
     */

    @Transactional
    public List<MemberItemResDto> getMemberItem(Long memberItemId) {
        Member member = memberRepository.findById(memberItemId)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        List<MemberItem> response = memberItemRepository.findAllByMember(member);

        return response.stream()
            .map(MemberItemResDto::fromEntity)
            .collect(Collectors.toList());
    }
}
