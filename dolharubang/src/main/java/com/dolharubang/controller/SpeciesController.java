package com.dolharubang.controller;

import com.dolharubang.domain.dto.request.SpeciesReqDto;
import com.dolharubang.domain.dto.response.SpeciesResDto;
import com.dolharubang.service.SpeciesService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@Tag(name = "Species", description = "APIs for managing species")
@RestController
@RequestMapping("/api/v1/species")
public class SpeciesController {

    private final SpeciesService speciesService;

    public SpeciesController(SpeciesService speciesService) {
        this.speciesService = speciesService;
    }

    @Operation(summary = "돌 종류 생성", description = "새로운 돌 종류를 생성한다.")
    @PostMapping
    public ResponseEntity<SpeciesResDto> createSpecies(@RequestBody SpeciesReqDto requestDto) {
        SpeciesResDto response = speciesService.createSpecies(requestDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @Operation(summary = "돌 종류 수정", description = "해당 species_id의 돌 종류 정보를 수정한다.")
    @PutMapping("/{id}")
    public ResponseEntity<SpeciesResDto> updateSpecies(@PathVariable Long id, @RequestBody SpeciesReqDto requestDto) {
        SpeciesResDto response = speciesService.updateSpecies(id, requestDto);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "돌 종류 상세 조회", description = "species_id로 하나의 돌 종류를 조회한다.")
    @GetMapping("/{id}")
    public ResponseEntity<SpeciesResDto> getSpecies(@PathVariable Long id) {
        SpeciesResDto response = speciesService.getSpecies(id);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "돌 종류 전체 조회", description = "모든 돌 종류 정보를 조회한다.")
    @GetMapping
    public ResponseEntity<List<SpeciesResDto>> getAllSpecies() {
        List<SpeciesResDto> response = speciesService.getAllSpecies();
        return ResponseEntity.ok(response);
    }
}