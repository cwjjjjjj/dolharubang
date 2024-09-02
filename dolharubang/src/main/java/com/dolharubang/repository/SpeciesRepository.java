package com.dolharubang.repository;

import com.dolharubang.domain.entity.Species;
import java.util.List;

public interface SpeciesRepository {

    List<Species> findAll();

    List<Species> findBySpeciesName(String speciesName);
}
