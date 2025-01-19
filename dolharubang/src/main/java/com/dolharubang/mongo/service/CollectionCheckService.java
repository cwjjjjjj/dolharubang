package com.dolharubang.mongo.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.stereotype.Service;

//TODO 테스트용 클래스
@Service
public class CollectionCheckService {

    @Autowired
    private MongoTemplate mongoTemplate;

    public void checkCollections() {
        // 데이터베이스에서 컬렉션 이름 가져오기
        System.out.println("Collections in the database:");
        mongoTemplate.getCollectionNames().forEach(System.out::println);
        System.out.println("Connected to database: " + mongoTemplate.getDb().getName());
    }
}
