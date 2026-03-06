package com.aliparwiz.microgreens.plant;

import com.aliparwiz.microgreens.auth.User;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Plant Entity
 * Represents a microgreen plant tracked by the user
 */
@Entity
@Table(name = "plants")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Plant {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private String name;
    
    @Column(name = "plant_type", nullable = false)
    private String plantType; // e.g., "Basil", "Arugula", "Mint", "Cilantro"
    
    @Column(columnDefinition = "TEXT")
    private String description;
    
    @Column(name = "planting_date")
    private LocalDate plantingDate;
    
    @Column(name = "growth_stage")
    private String growthStage = "Seedling"; // "Seedling", "Growing", "Ready to Harvest", "Harvested"
    
    @Column(name = "health_status")
    private String healthStatus; // "Healthy", "Needs Water", "Warning"
    
    @Column(columnDefinition = "TEXT")
    private String notes;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt = LocalDateTime.now();
    
    // Many plants belong to one user
    @JsonIgnore
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User owner;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
