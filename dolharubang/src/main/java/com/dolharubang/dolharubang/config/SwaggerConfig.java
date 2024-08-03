package com.dolharubang.dolharubang.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class SwaggerConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
            .info(new Info()
                .title("Schedule API")
                .version("1.0")
                .description("API documentation for the Schedule Management System")
                .contact(new Contact()
                    .name("돌하루방")
                    .url("https://www.dolharubang.com")));
    }
}
