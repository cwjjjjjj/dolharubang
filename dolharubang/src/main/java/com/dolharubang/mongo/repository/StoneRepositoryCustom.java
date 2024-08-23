package com.dolharubang.mongo.repository;

import lombok.RequiredArgsConstructor;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.stereotype.Repository;

@RequiredArgsConstructor
@Repository
public class StoneRepositoryCustom {
    private final MongoTemplate mongoTemplate;
    //TODO StoneRepositoryCustom 작성
}
