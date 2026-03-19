package com.spring.RestDemo.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class FacilityRequest {
    private Long id;

    @NotBlank(message = "name is required")
    private String name;

    private String description;
}
