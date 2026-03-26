package com.aliparwiz.microgreens.plant;

import com.aliparwiz.microgreens.auth.AuthRepository;
import com.aliparwiz.microgreens.auth.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;

/**
 * Plant Service
 * Business logic for plant management
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class PlantService {
    
    private final PlantRepository plantRepository;
    private final AuthRepository authRepository;
    
    /**
     * Get all plants for current user (or all if admin)
     */
    public List<Plant> getAllPlants() {
        if (isCurrentUserAdmin()) {
            return plantRepository.findAll();
        }

        Long userId = getCurrentUserId();
        if (userId == null) {
            return List.of();
        }
        return plantRepository.findByOwnerId(userId);
    }
    
    /**
     * Get current user ID from security context
     */
    private Long getCurrentUserId() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()) {
            return null;
        }
        String email = auth.getName();
        return authRepository.findByEmail(email)
            .map(User::getId)
            .orElse(null);
    }

    /**
     * Check if current user is admin
     */
    private boolean isCurrentUserAdmin() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()) {
            return false;
        }

        return auth.getAuthorities().stream()
            .anyMatch(authority -> "ROLE_ADMIN".equals(authority.getAuthority()));
    }
    
    /**
     * Get plant by ID (ensuring it belongs to current user or user is admin)
     */
    public Plant getPlantById(Long id) {
        Plant plant = plantRepository.findById(Objects.requireNonNull(id, "Plant id is required"))
            .orElseThrow(() -> new RuntimeException("Plant not found"));

        if (isCurrentUserAdmin()) {
            return plant;
        }

        Long userId = getCurrentUserId();
        if (userId == null || plant.getOwner() == null || !plant.getOwner().getId().equals(userId)) {
            throw new RuntimeException("Access denied: This plant does not belong to you");
        }

        return plant;
    }
    
    /**
     * Create a new plant for current user
     */
    @Transactional
    public Plant createPlant(Plant plant) {
        // Set current user as owner
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()) {
            throw new RuntimeException("User must be authenticated to create a plant");
        }
        
        String email = auth.getName();
        User owner = authRepository.findByEmail(email)
            .orElseThrow(() -> new RuntimeException("User not found"));
        plant.setOwner(owner);
        
        plant.setCreatedAt(LocalDateTime.now());
        plant.setUpdatedAt(LocalDateTime.now());
        
        Plant savedPlant = plantRepository.save(plant);
        log.info("[PLANT] Created plant: name='{}', owner='{}'", savedPlant.getName(), email);
        return savedPlant;
    }
    
    /**
     * Update an existing plant
     */
    @Transactional
    public Plant updatePlant(Long id, Plant plantDetails) {
        Plant plant = getPlantById(id); // This checks ownership
        
        if (plantDetails.getName() != null) {
            plant.setName(plantDetails.getName());
        }
        if (plantDetails.getPlantType() != null) {
            plant.setPlantType(plantDetails.getPlantType());
        }
        if (plantDetails.getDescription() != null) {
            plant.setDescription(plantDetails.getDescription());
        }
        if (plantDetails.getPlantingDate() != null) {
            plant.setPlantingDate(plantDetails.getPlantingDate());
        }
        if (plantDetails.getGrowthStage() != null) {
            plant.setGrowthStage(plantDetails.getGrowthStage());
        }
        if (plantDetails.getHealthStatus() != null) {
            plant.setHealthStatus(plantDetails.getHealthStatus());
        }
        if (plantDetails.getNotes() != null) {
            plant.setNotes(plantDetails.getNotes());
        }
        
        plant.setUpdatedAt(LocalDateTime.now());
        return plantRepository.save(plant);
    }
    
    /**
     * Delete a plant
     */
    @Transactional
    public void deletePlant(Long id) {
        Plant plant = getPlantById(id); // This checks ownership
        plantRepository.delete(Objects.requireNonNull(plant, "Plant must not be null"));
        log.info("[PLANT] Deleted plant: name='{}'", plant.getName());
    }
    
    /**
     * Get plants by growth stage for current user
     */
    public List<Plant> getPlantsByGrowthStage(String growthStage) {
        Long userId = getCurrentUserId();
        if (userId == null) {
            return List.of();
        }
        return plantRepository.findByOwnerIdAndGrowthStage(userId, growthStage);
    }
    
    /**
     * Get plants by type for current user
     */
    public List<Plant> getPlantsByType(String plantType) {
        Long userId = getCurrentUserId();
        if (userId == null) {
            return List.of();
        }
        return plantRepository.findByOwnerIdAndPlantType(userId, plantType);
    }
}
