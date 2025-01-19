package com.dolharubang.service;

import com.dolharubang.domain.entity.Member;
import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import com.dolharubang.repository.MemberRepository;
import com.dolharubang.repository.StoneRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
public class StoneService {

    private final StoneRepository stoneRepository;
    private final MemberRepository memberRepository;

    public StoneService(StoneRepository stoneRepository, MemberRepository memberRepository) {
        this.stoneRepository = stoneRepository;
        this.memberRepository = memberRepository;
    }

    //TODO 입양 부분(create) 구현

    @Transactional(readOnly = true)
    public String readSignText(Long memberId) {
        Member member = memberRepository.findByMemberId(memberId)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        String signText = "";
        signText = stoneRepository.findSignTextByMember(member)
            .orElseThrow(() -> new CustomException(ErrorCode.SIGNTEXT_NOT_FOUND));

        return signText;
    }
}
