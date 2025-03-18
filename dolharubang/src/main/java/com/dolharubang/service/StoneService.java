package com.dolharubang.service;

import com.dolharubang.domain.dto.request.StoneTextUpdateReqDto;
import com.dolharubang.domain.dto.request.StoneReqDto;
import com.dolharubang.domain.dto.response.stone.StoneProfileResDto;
import com.dolharubang.domain.dto.response.stone.StoneResDto;
import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.Species;
import com.dolharubang.domain.entity.Stone;
import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import com.dolharubang.repository.MemberRepository;
import com.dolharubang.repository.SpeciesRepository;
import com.dolharubang.repository.StoneRepository;
import com.dolharubang.type.AbilityType;
import java.util.Arrays;
import java.util.Map;
import java.util.stream.Collectors;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
public class StoneService {

    private final StoneRepository stoneRepository;
    private final MemberRepository memberRepository;
    private final SpeciesRepository speciesRepository;

    public StoneService(StoneRepository stoneRepository, MemberRepository memberRepository, SpeciesRepository speciesRepository) {
        this.stoneRepository = stoneRepository;
        this.memberRepository = memberRepository;
        this.speciesRepository = speciesRepository;
    }

    @Transactional
    public StoneResDto adoptStone(StoneReqDto stoneReqDto) {
        Member member = memberRepository.findById(stoneReqDto.getMemberId())
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        Species species = speciesRepository.findById(stoneReqDto.getSpeciesId())
            .orElseThrow(() -> new CustomException(ErrorCode.SPECIES_NOT_FOUND));

        Map<AbilityType, Boolean> abilityMap = Arrays.stream(AbilityType.values()).collect(
            Collectors.toMap(
                ability -> ability,
                ability -> ability == species.getBaseAbility()
            ));

        Stone stone = Stone.builder()
            .member(member)
            .speciesId(stoneReqDto.getSpeciesId())
            .stoneName(stoneReqDto.getStoneName())
            .closeness(stoneReqDto.getCloseness())
            .abilityAble(abilityMap)
            .signText(stoneReqDto.getSignText())
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
        if (signText == null) {
            throw new CustomException(ErrorCode.SIGNTEXT_NOT_FOUND);
        }
        return signText;
    }

    @Transactional(readOnly = true)
    public StoneProfileResDto getStoneProfile(Long memberId) {
        Stone stone = findStoneByMemberId(memberId);

        Species species = speciesRepository.findById(stone.getSpeciesId())
            .orElseThrow(() -> new CustomException(ErrorCode.SPECIES_NOT_FOUND));

        return StoneProfileResDto.fromEntity(stone, species);
    }

    @Transactional
    public String updateStoneName(Long memberId, StoneTextUpdateReqDto dto) {
        Stone stone = findStoneByMemberId(memberId);
        return dto.updateStoneName(stone);
    }

    @Transactional
    public String updateSignText(Long memberId, StoneTextUpdateReqDto dto) {
        Stone stone = findStoneByMemberId(memberId);
        return dto.updateSignText(stone);
    }

    @Transactional(readOnly = true)
    public Map<AbilityType, Boolean> readAbilityAble(Long memberId) {
        Stone stone = findStoneByMemberId(memberId);
        return stone.getAbilityAble();
    }

    @Transactional
    public Map<AbilityType, Boolean> updateAbilityAble(Long memberId, AbilityType abilityType) {
        Stone stone = findStoneByMemberId(memberId);
        stone.updateAbilityAble(abilityType);
        return stone.getAbilityAble();
    }

    private Stone findStoneByMemberId(Long memberId) {
        Member member = memberRepository.findById(memberId)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        return stoneRepository.findByMember(member)
            .orElseThrow(() -> new CustomException(ErrorCode.STONE_NOT_FOUND));
    }
}
