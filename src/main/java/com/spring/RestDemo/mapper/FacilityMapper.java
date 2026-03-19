package com.spring.RestDemo.mapper;

import com.spring.RestDemo.dto.FacilityRequest;
import com.spring.RestDemo.dto.FacilityResponse;
import com.spring.RestDemo.entity.Facility;
import com.spring.RestDemo.model.FacilityModel;

public final class FacilityMapper {
    private FacilityMapper() {}

    public static FacilityModel toModel(Facility entity) {
        if (entity == null) return null;
        return new FacilityModel(entity.getId(), entity.getName(), entity.getDescription());
    }

    public static FacilityResponse toDto(FacilityModel model) {
        if (model == null) return null;
        return new FacilityResponse(model.getId(), model.getName(), model.getDescription());
    }

    public static FacilityModel toModel(FacilityResponse dto) {
        if (dto == null) return null;
        return new FacilityModel(dto.getId(), dto.getName(), dto.getDescription());
    }

    public static FacilityModel toModel(FacilityRequest req) {
        if (req == null) return null;
        return new FacilityModel(req.getId(), req.getName(), req.getDescription());
    }

    public static Facility toEntity(FacilityModel model) {
        if (model == null) return null;
        Facility entity = new Facility();
        entity.setName(model.getName());
        entity.setDescription(model.getDescription());
        return entity;
    }
}
