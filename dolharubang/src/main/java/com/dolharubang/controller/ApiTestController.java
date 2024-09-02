package com.dolharubang.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.HashMap;
import java.util.Map;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@Tag(name = "TEST", description = "희태용 API")
@RestController
@RequestMapping("/api/v1/pepperoni")
public class ApiTestController {

    @Operation(summary = "페퍼로니 출력하기")
    @GetMapping(produces = "application/json")
    public Map<String, String> getPepperoni() {
        Map<String, String> response = new HashMap<>();
        response.put("message", "페퍼로니페퍼로니페퍼로니페퍼로니");
        return response;
    }
}
