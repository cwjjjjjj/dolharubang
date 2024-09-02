package com.dolharubang.mongo.repository;

import com.dolharubang.mongo.entity.Stone;
import java.util.Optional;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface StoneRepository extends MongoRepository<Stone, String> {

    Optional<Stone> findByStoneId(ObjectId stoneId);

    Optional<Stone> findByMemberId(Long memberId);


}
