package com.aliparwiz.microgreens.ai;

import com.aliparwiz.microgreens.device.Device;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Prediction Entity
 * Represents an AI-generated prediction for a device
 */
@Entity
@Table(name = "predictions")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Prediction {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "prediction_type")
    private String predictionType; // e.g., "harvest_time", "growth_rate", "health_status"
    
    @Column(name = "prediction_data", columnDefinition = "TEXT")
    private String predictionData; // JSON string containing prediction results
    
    @Column(name = "confidence_score")
    private Double confidenceScore;
    
    @Column(name = "model_version")
    private String modelVersion;
    
    @Column(name = "timestamp")
    private LocalDateTime timestamp = LocalDateTime.now();
    
    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();
    
    // Many predictions belong to one device
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "device_id", nullable = false)
    private Device device;
}

