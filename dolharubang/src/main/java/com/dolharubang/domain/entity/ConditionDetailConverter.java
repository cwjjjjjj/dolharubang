package com.dolharubang.domain.entity;

import com.dolharubang.domain.dto.common.ConditionDetail;
import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;

@Converter
public class ConditionDetailConverter implements AttributeConverter<ConditionDetail, String> {

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public String convertToDatabaseColumn(ConditionDetail attribute) {
        if (attribute == null) {
            return null;
        }
        try {
            return objectMapper.writeValueAsString(attribute);
        } catch (JsonProcessingException e) {
            throw new CustomException(ErrorCode.JSON_CONVERSION_ERROR);
        }
    }

    @Override
    public ConditionDetail convertToEntityAttribute(String dbData) {
        if (dbData == null || dbData.isEmpty()) {
            return null;
        }
        try {
            return objectMapper.readValue(dbData, ConditionDetail.class);
        } catch (JsonProcessingException e) {
            throw new CustomException(ErrorCode.JSON_CONVERSION_ERROR);
        }
    }
}
