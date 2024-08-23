package com.dolharubang.mongo.repository;

import com.dolharubang.mongo.entity.Stone;
import java.util.Optional;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface StoneRepository extends MongoRepository<Stone, String> {

    Optional<Stone> findById(String id);

    Optional<Stone>  findByMemberEmail(String memberEmail);
}
