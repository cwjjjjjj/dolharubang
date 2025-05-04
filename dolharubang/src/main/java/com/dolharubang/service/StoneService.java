package com.dolharubang.service;

import com.dolharubang.domain.dto.request.StoneReqDto;
import com.dolharubang.domain.dto.request.StoneTextUpdateReqDto;
import com.dolharubang.domain.dto.response.stone.StoneHomeResDto;
import com.dolharubang.domain.dto.response.stone.StoneProfileResDto;
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
    public boolean adoptStone(Long memberId, StoneReqDto stoneReqDto) {

        Member member = memberRepository.findById(memberId)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        System.out.println("서비스 | 방이름: "+stoneReqDto.getSpaceName());

        Species species = speciesRepository.findBySpeciesName(stoneReqDto.getSpeciesName())
            .orElseThrow(() -> new CustomException(ErrorCode.SPECIES_NOT_FOUND));

        Map<AbilityType, Boolean> abilityMap = Arrays.stream(AbilityType.values()).collect(
            Collectors.toMap(
                ability -> ability,
                ability -> ability == species.getBaseAbility()
            ));

        Stone stone = Stone.builder()
            .member(member)
            .speciesId(species.getSpeciesId())
            .stoneName(stoneReqDto.getStoneName())
            .closeness(0L)
            .abilityAble(abilityMap)
            .signText("")
            .build();

        member.updateSpaceName(
            stoneReqDto.getSpaceName()
        );

        Stone adoptedStone = stoneRepository.save(stone);
        if (adoptedStone != null) {
            return true;
        }
        return false;
    }

    @Transactional
    public StoneProfileResDto updateStoneName(Long memberId, StoneTextUpdateReqDto dto) {
        Member member = memberRepository.findById(memberId)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        Stone stone = findStoneByMemberId(memberId);
        dto.updateStoneName(stone);

        Species species = speciesRepository.findById(stone.getSpeciesId())
            .orElseThrow(() -> new CustomException(ErrorCode.SPECIES_NOT_FOUND));

        return StoneProfileResDto.fromEntity(stone, species, member);
    }

    @Transactional
    public String updateSignText(Long memberId, StoneTextUpdateReqDto dto) {
        Stone stone = findStoneByMemberId(memberId);
        return dto.updateSignText(stone);
    }

    @Transactional(readOnly = true)
    public String readSignText(Long memberId) {
        Member member = memberRepository.findById(memberId)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        String signText = "";
        signText = stoneRepository.findSignTextByMember(member);
        if (signText == null) {
            throw new CustomException(ErrorCode.SIGN_TEXT_NOT_FOUND);
        }
        return signText;
    }

    @Transactional(readOnly = true)
    public StoneProfileResDto getStoneProfile(Long memberId) {
        Member member = memberRepository.findById(memberId)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        Stone stone = findStoneByMemberId(memberId);

        Species species = speciesRepository.findById(stone.getSpeciesId())
            .orElseThrow(() -> new CustomException(ErrorCode.SPECIES_NOT_FOUND));

        return StoneProfileResDto.fromEntity(stone, species, member);
    }

    @Transactional(readOnly = true)
    public StoneHomeResDto getStoneHomeInfo(Long memberId) {
        Stone stone = findStoneByMemberId(memberId);

        return StoneHomeResDto.fromEntity(stone);
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
