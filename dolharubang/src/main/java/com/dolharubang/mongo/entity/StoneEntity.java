package com.dolharubang.mongo.entity;

import jakarta.persistence.Id;
import java.util.Dictionary;
import java.util.Map;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.mapping.Document;

//유저가 가지고 있는 반려돌에 대한 정보를 불러오거나 갱신하기 위한 Entity
@Document
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Data
public class StoneEntity {

    @Id
    private ObjectId stone_id;

    private String memberEmail;

    private long speciesId;

    private String stoneName;

    private String createAt;

    private long closeness;

    private Map<String, Boolean> ability_able;

    private String sign_text;

    private CustomDataEntity custom;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class CustomDataEntity {
        //배경
        private Map<String, Map<String, CustomItem>> background;

        //배경 소품
        private Map<String, Map<String, CustomItem>> back_prop;

        //돌받침
        private Map<String, Map<String, CustomItem>> support;

        //악세사리
        private Map<String, Map<String, CustomItem>> accs;

        //이목구비
        private Map<String, Map<String, CustomItem>> facialFeatures;

        //팻말
        private Map<String, Map<String, CustomItem>> sign;

        //특수아이템
        private Map<String, Map<String, CustomItem>> specialItem;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class CustomItem {
        private String url;
        private Double xCoordinate;
        private Double yCoordinate;
    }
}
