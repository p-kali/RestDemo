package com.spring.RestDemo.config;

import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.info.Info;
import org.springframework.context.annotation.Configuration;

/**
 * http://localhost:8080/swagger-ui.html
 * http://localhost:8080/swagger-ui/index.html
 * http://localhost:8080/v3/api-docs
 */
@Configuration
@OpenAPIDefinition(
        info = @Info(
                title = "Rest Demo API",
                version = "1.0",
                description = "Spring Boot REST Demo APIs"
        )
)
public class OpenApiConfig {
}
