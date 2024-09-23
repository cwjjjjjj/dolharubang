package com.dolharubang.service;

import com.dolharubang.domain.dto.request.MemberItemReqDto;
import com.dolharubang.domain.dto.response.MemberItemResDto;
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

    //새로운 아이템이 추가될 경우 모든 멤버에 대해 실행하는 메서드
    @Transactional
    public MemberItemResDto createMemberItem(MemberItemReqDto memberItemReqDto) {
        Member member = memberRepository.findByMemberId(memberItemReqDto.getMemberId())
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
    public MemberItemResDto updateItemOwnership(Long memberItemId) {
        MemberItem memberItem = memberItemRepository.findById(memberItemId)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBERITEM_NOT_FOUND));
        System.out.println(memberItem.getItemId());

        Member member = memberRepository.findByMemberId(memberItem.getMember().getMemberId())
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        Item item = itemService.findByItemId(memberItem.getItemId())
            .orElseThrow(() -> new CustomException(ErrorCode.ITEM_NOT_FOUND));

        if(memberItem.isWhetherHasItem()) {
            throw new CustomException(ErrorCode.ALREADY_BOUGHT);
        }

        if(member.getSands() < item.getPrice()) {
            throw new CustomException(ErrorCode.LACK_OF_SAND);
        }
        member.deductSands(item.getPrice());

        memberItem.update(
            member,
            memberItem.getItemId(),
            true
        );

        memberRepository.save(member);

        return MemberItemResDto.fromEntity(memberItem);
    }

    @Transactional
    public List<MemberItemResDto> getMemberItem(Long memberItemId) {
        Member member = memberRepository.findByMemberId(memberItemId)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        List<MemberItem> response = memberItemRepository.findAllByMember(member);

        return response.stream()
            .map(MemberItemResDto::fromEntity)
            .collect(Collectors.toList());
    }
}
