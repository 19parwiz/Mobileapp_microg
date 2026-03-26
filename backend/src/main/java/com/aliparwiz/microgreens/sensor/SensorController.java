package com.aliparwiz.microgreens.sensor;

import com.aliparwiz.microgreens.device.Device;
import com.aliparwiz.microgreens.sensor.dto.SensorReadingRequest;
import com.aliparwiz.microgreens.sensor.dto.SensorReadingResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/sensors")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class SensorController {
    
    private final SensorService sensorService;
    private final SensorDailyArchiveService dailyArchiveService;
    
    @PostMapping("/readings")
    public ResponseEntity<?> saveReading(@Valid @RequestBody SensorReadingRequest request) {
        try {
            SensorReading saved = sensorService.saveReading(toEntity(request));
            return ResponseEntity.ok(toResponse(saved));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body(Map.of("message", "Failed to save reading: " + e.getMessage()));
        }
    }
    
    @PostMapping("/readings/batch")
    public ResponseEntity<?> saveReadings(@Valid @RequestBody List<SensorReadingRequest> requests) {
        try {
            List<SensorReading> saved = sensorService.saveReadings(
                requests.stream()
                    .map(this::toEntity)
                    .toList()
            );
            return ResponseEntity.ok(
                saved.stream()
                    .map(this::toResponse)
                    .toList()
            );
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body(Map.of("message", "Failed to save readings: " + e.getMessage()));
        }
    }
    
    @GetMapping("/readings/device/{deviceId}")
    public ResponseEntity<List<SensorReadingResponse>> getReadingsByDeviceId(@PathVariable String deviceId) {
        return ResponseEntity.ok(
            sensorService.getReadingsByDeviceId(deviceId).stream()
                .map(this::toResponse)
                .toList()
        );
    }
    
    @GetMapping("/readings/device/{deviceId}/sensor/{sensorType}")
    public ResponseEntity<List<SensorReadingResponse>> getReadingsByDeviceAndSensor(
            @PathVariable String deviceId,
            @PathVariable String sensorType) {
        return ResponseEntity.ok(
            sensorService.getReadingsByDeviceIdAndSensorType(deviceId, sensorType).stream()
                .map(this::toResponse)
                .toList()
        );
    }

    @GetMapping("/readings/device/{deviceId}/date/{date}")
    public ResponseEntity<List<SensorReadingResponse>> getReadingsByDeviceAndDate(
            @PathVariable String deviceId,
            @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        return ResponseEntity.ok(
            sensorService.getReadingsByDeviceIdAndDate(deviceId, date).stream()
                .map(this::toResponse)
                .toList()
        );
    }
    
    @GetMapping("/readings/device/{deviceId}/latest")
    public ResponseEntity<List<SensorReadingResponse>> getLatestReadingsByDeviceId(@PathVariable String deviceId) {
        return ResponseEntity.ok(
            sensorService.getLatestReadingsByDeviceId(deviceId).stream()
                .map(this::toResponse)
                .toList()
        );
    }
    
    @GetMapping("/readings/device/{deviceId}/sensor/{sensorType}/latest")
    public ResponseEntity<SensorReadingResponse> getLatestReadingByDeviceAndSensor(
            @PathVariable String deviceId,
            @PathVariable String sensorType) {
        Optional<SensorReading> reading = sensorService.getLatestReadingByDeviceIdAndSensorType(deviceId, sensorType);
        if (reading.isPresent()) {
            return ResponseEntity.ok(toResponse(reading.get()));
        }
        return ResponseEntity.notFound().build();
    }
    
    @GetMapping("/readings")
    public ResponseEntity<List<SensorReadingResponse>> getAllReadings() {
        return ResponseEntity.ok(
            sensorService.getAllReadings().stream()
                .map(this::toResponse)
                .toList()
        );
    }

    @GetMapping("/readings/device/{deviceId}/daily-summary")
    public ResponseEntity<List<SensorDailySummary>> getDailySummaryByDevice(@PathVariable String deviceId) {
        return ResponseEntity.ok(sensorService.getDailySummariesByDeviceId(deviceId));
    }

    @PostMapping("/archive/daily/{date}")
    public ResponseEntity<?> archiveDailyReadings(
            @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        try {
            List<SensorDailyArchive> archived = dailyArchiveService.archiveDay(date);
            return ResponseEntity.ok(Map.of(
                    "message", "Daily archive completed",
                    "date", date.toString(),
                    "rows", archived.size()
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", "Failed to archive daily readings: " + e.getMessage()));
        }
    }

    @GetMapping("/archive/daily/{date}")
    public ResponseEntity<List<SensorDailyArchive>> getArchivedDailyReadings(
            @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        return ResponseEntity.ok(dailyArchiveService.getArchiveForDay(date));
    }

    private SensorReading toEntity(SensorReadingRequest request) {
        SensorReading reading = new SensorReading();
        Device device = new Device();
        device.setId(request.getDeviceId());

        reading.setDevice(device);
        reading.setSensorType(request.getSensorType());
        reading.setValue(request.getValue());
        reading.setUnit(request.getUnit());
        return reading;
    }

    private SensorReadingResponse toResponse(SensorReading reading) {
        return SensorReadingResponse.builder()
            .id(reading.getId())
            .sensorType(reading.getSensorType())
            .value(reading.getValue())
            .unit(reading.getUnit())
            .timestamp(reading.getTimestamp())
            .build();
    }
}

