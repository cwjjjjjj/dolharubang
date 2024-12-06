package com.dolharubang.repository;

import com.dolharubang.domain.entity.Species;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SpeciesRepository extends JpaRepository<Species, Long> {

    List<Species> findAll();

    Optional<Species> findBySpeciesName(String speciesName);
}