package com.spring.RestDemo.service;


import com.spring.RestDemo.dto.FacilityRequest;
import com.spring.RestDemo.dto.FacilityResponse;

import java.util.List;

public interface FacilityService {
    List<FacilityResponse> getAllFacilities();

    FacilityResponse getFacilityById(Long id);

    FacilityResponse createFacility(FacilityRequest request);

}
