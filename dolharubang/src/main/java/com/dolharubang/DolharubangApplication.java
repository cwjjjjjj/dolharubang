package com.dolharubang;

import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.servers.Server;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.web.client.RestTemplate;

@OpenAPIDefinition(
    servers = {
        @Server(url = "/", description = "Default Server url")
    }
)
@SpringBootApplication
@EnableJpaAuditing
@EnableScheduling
public class DolharubangApplication {

    public static void main(String[] args) {
        SpringApplication.run(DolharubangApplication.class, args);
    }

    @Bean
    public RestTemplate restTemplate(){
        return new RestTemplate();
    }
}
