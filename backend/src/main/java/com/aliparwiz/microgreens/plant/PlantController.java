package com.aliparwiz.microgreens.plant;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * Plant Controller
 * REST API endpoints for plant management
 */
@RestController
@RequestMapping("/api/plants")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class PlantController {
    
    private final PlantService plantService;
    
    /**
     * GET /api/plants - Get all plants for current user
     */
    @GetMapping
    public ResponseEntity<List<Plant>> getAllPlants() {
        return ResponseEntity.ok(plantService.getAllPlants());
    }
    
    /**
     * GET /api/plants/{id} - Get plant by ID
     */
    @GetMapping("/{id}")
    public ResponseEntity<?> getPlantById(@PathVariable Long id) {
        try {
            Plant plant = plantService.getPlantById(id);
            return ResponseEntity.ok(plant);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest()
                .body(Map.of("message", e.getMessage()));
        }
    }
    
    /**
     * GET /api/plants/stage/{growthStage} - Get plants by growth stage
     */
    @GetMapping("/stage/{growthStage}")
    public ResponseEntity<List<Plant>> getPlantsByGrowthStage(@PathVariable String growthStage) {
        return ResponseEntity.ok(plantService.getPlantsByGrowthStage(growthStage));
    }
    
    /**
     * GET /api/plants/type/{plantType} - Get plants by type
     */
    @GetMapping("/type/{plantType}")
    public ResponseEntity<List<Plant>> getPlantsByType(@PathVariable String plantType) {
        return ResponseEntity.ok(plantService.getPlantsByType(plantType));
    }
    
    /**
     * POST /api/plants - Create a new plant
     */
    @PostMapping
    public ResponseEntity<?> createPlant(@RequestBody Plant plant) {
        try {
            Plant created = plantService.createPlant(plant);
            return ResponseEntity.ok(created);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest()
                .body(Map.of("message", e.getMessage()));
        }
    }
    
    /**
     * PUT /api/plants/{id} - Update an existing plant
     */
    @PutMapping("/{id}")
    public ResponseEntity<?> updatePlant(
            @PathVariable Long id,
            @RequestBody Plant plantDetails) {
        try {
            Plant updated = plantService.updatePlant(id, plantDetails);
            return ResponseEntity.ok(updated);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest()
                .body(Map.of("message", e.getMessage()));
        }
    }
    
    /**
     * DELETE /api/plants/{id} - Delete a plant
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, String>> deletePlant(@PathVariable Long id) {
        try {
            plantService.deletePlant(id);
            return ResponseEntity.ok(Map.of("message", "Plant deleted successfully"));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest()
                .body(Map.of("message", e.getMessage()));
        }
    }
}
