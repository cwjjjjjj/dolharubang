package com.dolharubang.domain.dto.oauth;

import lombok.Builder;
import lombok.Data;

@Builder
@Data
public class AppleDTO {
    private String sub;
    private String email;
    private String name;
}
