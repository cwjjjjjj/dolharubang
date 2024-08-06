package com.dolharubang.mongo.repository;

import com.dolharubang.mongo.entity.StoneEntity;
import java.util.Optional;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface StoneRepository extends MongoRepository<StoneEntity, String> {

    Optional<StoneEntity> findById(@Param("id") ObjectId id);

    Optional<StoneEntity>  findByMemberEmail(String memberEmail);
}
