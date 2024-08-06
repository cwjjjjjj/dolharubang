package com.dolharubang.mongo.repository;

import com.dolharubang.mongo.entity.StoneEntity;
import lombok.RequiredArgsConstructor;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.stereotype.Repository;

@RequiredArgsConstructor
@Repository
public class StoneRepositoryCustom {
    private final MongoTemplate mongoTemplate;

//    public List<StoneEntity>
}
