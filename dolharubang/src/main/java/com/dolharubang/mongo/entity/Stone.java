package com.dolharubang.mongo.entity;

import jakarta.persistence.Id;
import java.time.LocalDateTime;
import java.util.Map;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.mapping.Document;

@Document
@Builder
@Data
public class Stone {

    @Id
    private ObjectId stoneId;

    private String memberId;

    private long speciesId;

    private String stoneName;

    private LocalDateTime createdAt;

    private long closeness;

    private Map<String, Boolean> abilityAble;

    private String signText;

    private CustomDataEntity custom;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class CustomDataEntity {
        //배경
        private Map<String, Map<String, CustomItem>> background;

        //배경 소품
        private Map<String, Map<String, CustomItem>> backProp;

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

    //TODO x, y 좌표 정보는 필요없음
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
