package com.dolharubang;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;

@SpringBootApplication(exclude={DataSourceAutoConfiguration.class})
public class DolharubangApplication {

    public static void main(String[] args) {
        SpringApplication.run(DolharubangApplication.class, args);
    }

}
