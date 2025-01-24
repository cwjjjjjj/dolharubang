package com.dolharubang.service;

import com.dolharubang.domain.dto.request.SpeciesReqDto;
import com.dolharubang.domain.dto.response.SpeciesResDto;
import com.dolharubang.domain.entity.Species;
import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import com.dolharubang.repository.SpeciesRepository;
import java.util.List;
import java.util.stream.Collectors;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
public class SpeciesService {
    private final SpeciesRepository speciesRepository;

    public SpeciesService(SpeciesRepository speciesRepository) {
        this.speciesRepository = speciesRepository;
    }

    @Transactional
    public SpeciesResDto createSpecies(SpeciesReqDto speciesReqDto) {
        Species species = Species.builder()
            .speciesName(speciesReqDto.getSpeciesName())
            .characteristic(speciesReqDto.getCharacteristic())
            .baseAbility(speciesReqDto.getBaseAbility())
            .build();

        Species savedSpecies = speciesRepository.save(species);
        return SpeciesResDto.fromEntity(savedSpecies);
    }

    @Transactional
    public SpeciesResDto updateSpecies(Long id, SpeciesReqDto speciesReqDto) {
        Species species = speciesRepository.findById(id)
            .orElseThrow(() -> new CustomException(ErrorCode.SPECIES_NOT_FOUND));

        Species updatedSpecies = Species.builder()
            .speciesId(id)
            .speciesName(speciesReqDto.getSpeciesName())
            .characteristic(speciesReqDto.getCharacteristic())
            .baseAbility(speciesReqDto.getBaseAbility())
            .build();

        Species savedSpecies = speciesRepository.save(updatedSpecies);
        return SpeciesResDto.fromEntity(savedSpecies);
    }

    @Transactional(readOnly = true)
    public SpeciesResDto getSpecies(Long id) {
        Species species = speciesRepository.findById(id)
            .orElseThrow(() -> new CustomException(ErrorCode.SPECIES_NOT_FOUND));

        return SpeciesResDto.fromEntity(species);
    }

    @Transactional(readOnly = true)
    public List<SpeciesResDto> getAllSpecies() {
        List<Species> speciesList = speciesRepository.findAll();

        if(speciesList.isEmpty()) {
            throw new CustomException(ErrorCode.SPECIES_NOT_FOUND);
        }

        return speciesList.stream()
            .map(SpeciesResDto::fromEntity)
            .collect(Collectors.toList());
    }
}
