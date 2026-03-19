package com.spring.RestDemo.repository;

import com.spring.RestDemo.entity.Facility;
import org.springframework.data.jpa.repository.JpaRepository;

public interface FacilityRepository extends JpaRepository<Facility, Long> {
}
