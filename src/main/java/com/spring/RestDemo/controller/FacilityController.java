package com.spring.RestDemo.controller;

import com.spring.RestDemo.dto.FacilityRequest;
import com.spring.RestDemo.dto.FacilityResponse;
import com.spring.RestDemo.service.FacilityService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.List;

@RestController
@RequestMapping("/api/facilities")
public class FacilityController {

    private final FacilityService facilityService;

    public FacilityController(FacilityService facilityService) {
        this.facilityService = facilityService;
    }

    @GetMapping
    public ResponseEntity<List<FacilityResponse>> getAll() {
        List<FacilityResponse> list = facilityService.getAllFacilities();
        return ResponseEntity.ok(list);
    }

    /**
     * Retrieve a facility by its id.
     * Returns 200 OK with the facility when found, or 404 Not Found when the facility does not exist.
     * @param id the identifier of the facility to retrieve
     * @return ResponseEntity containing the FacilityResponse or a 404 status
    */
    @GetMapping("/{id}")
    public ResponseEntity<FacilityResponse> getById(@PathVariable Long id) {
        FacilityResponse resp = facilityService.getFacilityById(id);
        if (resp == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(resp);
    }

    // Create facility - accept FacilityRequest and return 201 Created
    @PostMapping
    public ResponseEntity<FacilityResponse> createFacility(@Valid @RequestBody FacilityRequest request) {
        // creation will assign id; return created resource with Location header
        FacilityResponse created = facilityService.createFacility(request);
        URI location = URI.create(String.format("/api/facilities/%d", created.getId()));
        return ResponseEntity.created(location).body(created);
    }
}
