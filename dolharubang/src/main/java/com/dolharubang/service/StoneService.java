package com.dolharubang.service;

import com.dolharubang.domain.dto.request.StoneReqDto;
import com.dolharubang.domain.dto.response.StoneResDto;
import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.Stone;
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

    @Transactional
    public StoneResDto adoptStone(StoneReqDto stoneReqDto) {
        Member member = memberRepository.findById(stoneReqDto.getMemberId())
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        Stone stone = Stone.builder()
            .member(member)
            .speciesId(stoneReqDto.getSpeciesId())
            .stoneName(stoneReqDto.getStoneName())
            .closeness(stoneReqDto.getCloseness())
            .abilityAble(stoneReqDto.getAbilityAble())
            .signText(stoneReqDto.getSignText())
            .custom(stoneReqDto.getCustom())
            .build();

        Stone adoptedStone = stoneRepository.save(stone);
        return StoneResDto.fromEntity(adoptedStone);
    }

    @Transactional(readOnly = true)
    public String readSignText(Long memberId) {
        Member member = memberRepository.findById(memberId)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        String signText = "";
        signText = stoneRepository.findSignTextByMember(member);
        if(signText == null) {
            throw new CustomException(ErrorCode.SIGNTEXT_NOT_FOUND);
        }
        return signText;
    }
}
