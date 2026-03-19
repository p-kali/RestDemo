package com.spring.RestDemo.service.impl;

import com.spring.RestDemo.dto.FacilityRequest;
import com.spring.RestDemo.dto.FacilityResponse;
import com.spring.RestDemo.entity.Facility;
import com.spring.RestDemo.mapper.FacilityMapper;
import com.spring.RestDemo.model.FacilityModel;
import com.spring.RestDemo.repository.FacilityRepository;
import com.spring.RestDemo.service.FacilityService;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class FacilityServiceImpl implements FacilityService {
    private final FacilityRepository repository;

    public FacilityServiceImpl(FacilityRepository repository) {
        this.repository = repository;
    }

    @Override
    public List<FacilityResponse> getAllFacilities() {
        List<Facility> facilities = repository.findAll();
        return facilities.stream()
                .map(FacilityMapper::toModel)
                .map(FacilityMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public FacilityResponse getFacilityById(Long id) {
        Facility facility = repository.findById(id).orElse(null);
        if (facility == null) return null;
        FacilityModel model = FacilityMapper.toModel(facility);
        return FacilityMapper.toDto(model);
    }

    @Override
    public FacilityResponse createFacility(FacilityRequest request) {
        FacilityModel model = FacilityMapper.toModel(request);
        model.setId(null);
        Facility entity = FacilityMapper.toEntity(model);
        Facility saved = repository.save(entity);
        return FacilityMapper.toDto(FacilityMapper.toModel(saved));
    }
}


