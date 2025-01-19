package com.dolharubang.service;

import com.dolharubang.domain.dto.request.MemberReqDto;
import com.dolharubang.domain.dto.response.MemberResDto;
import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.MemberItem;
import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import com.dolharubang.mongo.entity.Item;
import com.dolharubang.mongo.repository.ItemRepository;
import com.dolharubang.repository.MemberItemRepository;
import com.dolharubang.repository.MemberRepository;
import java.util.List;
import java.util.stream.Collectors;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
public class MemberService {
    private final MemberRepository memberRepository;
    private final ItemRepository itemRepository;
    private final MemberItemRepository memberItemRepository;

    public MemberService(MemberRepository memberRepository, ItemRepository itemRepository, MemberItemRepository memberItemRepository) {
        this.memberRepository = memberRepository;
        this.itemRepository = itemRepository;
        this.memberItemRepository = memberItemRepository;
    }

    @Transactional(readOnly = true)
    public List<MemberResDto> getAllMembers() {
        List<Member> members = memberRepository.findAll();

        return members.stream()
            .map(MemberResDto::fromEntity)
            .collect(Collectors.toList());
    }

    @Transactional
    public MemberResDto createMember(MemberReqDto requestDto) {
        Member member = Member.builder()
            .memberEmail(requestDto.getMemberEmail())
            .nickname(requestDto.getNickname())
            .birthday(requestDto.getBirthday())
            .sands(requestDto.getSands())
            .totalLoginDays(requestDto.getTotalLoginDays())
            .profilePicture((requestDto.getProfilePicture()))
            .spaceName(requestDto.getSpaceName())
            .build();

        Member savedMember = memberRepository.save(member);

        //회원 가입 시 mongoDB의 모든 아이템 목록에 대해 false로 memberItem 생성
        List<Item> items = itemRepository.findAll();

        for (Item item : items) {
            MemberItem memberItem = MemberItem.builder()
                .member(savedMember)
                .itemId(item.getItemId().toString())
                .whetherHasItem(false)
                .build();
            memberItemRepository.save(memberItem);
        }

        return MemberResDto.fromEntity(savedMember);
    }

    @Transactional
    public MemberResDto updateMember(Long memberId, MemberReqDto requestDto) {
        Member member = memberRepository.findByMemberId(memberId)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND, "Member not found with ID: " + memberId));

        member.update(
            requestDto.getNickname(),
            requestDto.getSands(),
            requestDto.getProfilePicture(),
            requestDto.getSpaceName()
        );

        return MemberResDto.fromEntity(member);
    }

    @Transactional(readOnly = true)
    public MemberResDto getMember(Long memberId) {
        Member member = memberRepository.findByMemberId(memberId)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND, "Member not found with ID: " + memberId));

        return MemberResDto.fromEntity(member);
    }
}