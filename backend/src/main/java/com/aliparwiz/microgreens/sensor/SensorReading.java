package com.aliparwiz.microgreens.sensor;

import com.aliparwiz.microgreens.device.Device;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.ToString;

import java.time.LocalDateTime;

/**
 * Sensor Reading Entity
 * Represents a single sensor reading from an IoT device
 */
@Entity
@Table(name = "sensor_readings")
@Data
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(exclude = {"device"})
@ToString(exclude = {"device"})
public class SensorReading {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "sensor_type")
    private String sensorType; // e.g., "temperature", "humidity", "light", "soil_moisture"
    
    @Column(name = "value")
    private Double value;
    
    @Column(name = "unit")
    private String unit; // e.g., "Celsius", "RH%", "Lux", "%"
    
    @Column(name = "timestamp")
    private LocalDateTime timestamp = LocalDateTime.now();
    
    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();
    
    // Many sensor readings belong to one device
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "device_id", nullable = false)
    private Device device;
}

