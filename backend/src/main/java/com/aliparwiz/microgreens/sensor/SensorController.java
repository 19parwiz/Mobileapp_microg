package com.aliparwiz.microgreens.sensor;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/sensors")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class SensorController {
    
    private final SensorService sensorService;
    
    @PostMapping("/readings")
    public ResponseEntity<?> saveReading(@RequestBody SensorReading reading) {
        try {
            SensorReading saved = sensorService.saveReading(reading);
            return ResponseEntity.ok(saved);
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body(Map.of("message", "Failed to save reading: " + e.getMessage()));
        }
    }
    
    @PostMapping("/readings/batch")
    public ResponseEntity<?> saveReadings(@RequestBody List<SensorReading> readings) {
        try {
            List<SensorReading> saved = sensorService.saveReadings(readings);
            return ResponseEntity.ok(saved);
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body(Map.of("message", "Failed to save readings: " + e.getMessage()));
        }
    }
    
    @GetMapping("/readings/device/{deviceId}")
    public ResponseEntity<List<SensorReading>> getReadingsByDeviceId(@PathVariable String deviceId) {
        return ResponseEntity.ok(sensorService.getReadingsByDeviceId(deviceId));
    }
    
    @GetMapping("/readings/device/{deviceId}/sensor/{sensorType}")
    public ResponseEntity<List<SensorReading>> getReadingsByDeviceAndSensor(
            @PathVariable String deviceId,
            @PathVariable String sensorType) {
        return ResponseEntity.ok(sensorService.getReadingsByDeviceIdAndSensorType(deviceId, sensorType));
    }
    
    @GetMapping("/readings/device/{deviceId}/latest")
    public ResponseEntity<List<SensorReading>> getLatestReadingsByDeviceId(@PathVariable String deviceId) {
        return ResponseEntity.ok(sensorService.getLatestReadingsByDeviceId(deviceId));
    }
    
    @GetMapping("/readings/device/{deviceId}/sensor/{sensorType}/latest")
    public ResponseEntity<?> getLatestReadingByDeviceAndSensor(
            @PathVariable String deviceId,
            @PathVariable String sensorType) {
        Optional<SensorReading> reading = sensorService.getLatestReadingByDeviceIdAndSensorType(deviceId, sensorType);
        if (reading.isPresent()) {
            return ResponseEntity.ok(reading.get());
        }
        return ResponseEntity.notFound().build();
    }
    
    @GetMapping("/readings")
    public ResponseEntity<List<SensorReading>> getAllReadings() {
        return ResponseEntity.ok(sensorService.getAllReadings());
    }
}

