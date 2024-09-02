package com.dolharubang.service;

import com.dolharubang.domain.dto.request.HasItemReqDto;
import com.dolharubang.domain.dto.response.HasItemResDto;
import com.dolharubang.domain.entity.HasItem;
import com.dolharubang.domain.entity.Member;
import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import com.dolharubang.repository.HasItemRepository;
import com.dolharubang.repository.MemberRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
public class HasItemService {

    private final HasItemRepository repository;
    private final MemberRepository memberRepository;

    public HasItemService(HasItemRepository repository, MemberRepository memberRepository) {
        this.repository = repository;
        this.memberRepository = memberRepository;
    }

    @Transactional
    public HasItemResDto createHasItem(HasItemReqDto hasItemReqDto) {
        Member member = memberRepository.findById(hasItemReqDto.getMemberId())
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        HasItem hasItem = HasItem.builder()
            .member(member)
            .itemId(hasItemReqDto.getItemId())
            .itemType(hasItemReqDto.getItemType())
            .build();

        HasItem savedHasItem = repository.save(hasItem);
        return HasItemResDto.fromEntity(savedHasItem);
    }

    //TODO get 메서드 생성
}
