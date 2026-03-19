package com.spring.RestDemo.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Domain model representing a Facility. This is separate from the JPA entity and the API DTO.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class FacilityModel {
    private Long id;
    private String name;
    private String description;
}
