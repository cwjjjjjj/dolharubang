package com.dolharubang.domain.dto.common;

import com.dolharubang.domain.entity.Stone;
import lombok.Getter;

@Getter
public class StoneTextUpdateReqDto {

    private String text;

    public String updateStoneName(Stone stone) {
        stone.updateStoneName(this.text);
        return this.text;
    }

    public String updateSignText(Stone stone) {
        stone.updateSignText(this.text);
        return this.text;
    }
}
