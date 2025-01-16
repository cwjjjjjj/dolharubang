package com.dolharubang.service;

import com.dolharubang.domain.dto.request.MemberReqDto;
import com.dolharubang.domain.dto.response.MemberResDto;
import com.dolharubang.domain.entity.Member;
import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import com.dolharubang.mongo.repository.ItemRepository;
import com.dolharubang.repository.MemberItemRepository;
import com.dolharubang.repository.MemberRepository;
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