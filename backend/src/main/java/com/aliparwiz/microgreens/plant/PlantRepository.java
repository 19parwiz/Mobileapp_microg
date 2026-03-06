package com.aliparwiz.microgreens.plant;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Plant Repository
 * Data access layer for plant entities
 */
@Repository
public interface PlantRepository extends JpaRepository<Plant, Long> {
    
    /**
     * Find all plants belonging to a specific user
     */
    List<Plant> findByOwnerId(Long userId);
    
    /**
     * Find plant by ID and owner
     */
    Optional<Plant> findByIdAndOwnerId(Long id, Long userId);
    
    /**
     * Find plants by growth stage for a specific user
     */
    List<Plant> findByOwnerIdAndGrowthStage(Long userId, String growthStage);
    
    /**
     * Find plants by plant type for a specific user
     */
    List<Plant> findByOwnerIdAndPlantType(Long userId, String plantType);
}
