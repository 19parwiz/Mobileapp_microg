package com.aliparwiz.microgreens.sensor;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class SensorService {
    
    private final SensorRepository sensorRepository;
    
    @Transactional
    public SensorReading saveReading(SensorReading reading) {
        if (reading.getTimestamp() == null) {
            reading.setTimestamp(LocalDateTime.now());
        }
        reading.setCreatedAt(LocalDateTime.now());
        return sensorRepository.save(reading);
    }
    
    @Transactional
    public List<SensorReading> saveReadings(List<SensorReading> readings) {
        readings.forEach(reading -> {
            if (reading.getTimestamp() == null) {
                reading.setTimestamp(LocalDateTime.now());
            }
            reading.setCreatedAt(LocalDateTime.now());
        });
        return sensorRepository.saveAll(readings);
    }
    
    public List<SensorReading> getReadingsByDeviceId(String deviceId) {
        return sensorRepository.findByDevice_DeviceId(deviceId);
    }
    
    public List<SensorReading> getReadingsByDeviceIdAndSensorType(String deviceId, String sensorType) {
        return sensorRepository.findByDevice_DeviceIdAndSensorType(deviceId, sensorType);
    }

    public List<SensorReading> getReadingsByDeviceIdAndDate(String deviceId, LocalDate date) {
        LocalDateTime start = date.atStartOfDay();
        LocalDateTime end = date.plusDays(1).atStartOfDay();
        return sensorRepository.findByDevice_DeviceIdAndTimestampBetween(deviceId, start, end);
    }
    
    public List<SensorReading> getLatestReadingsByDeviceId(String deviceId) {
        return sensorRepository.findLatestByDeviceId(deviceId);
    }
    
    public Optional<SensorReading> getLatestReadingByDeviceIdAndSensorType(String deviceId, String sensorType) {
        return sensorRepository.findLatestByDeviceIdAndSensorType(deviceId, sensorType);
    }
    
    public List<SensorReading> getAllReadings() {
        return sensorRepository.findAll();
    }

    public List<SensorDailySummary> getDailySummariesByDeviceId(String deviceId) {
        return sensorRepository.findDailySummariesByDeviceId(deviceId).stream()
                .map(row -> new SensorDailySummary(
                        (LocalDate) row[0],
                        (String) row[1],
                        row[2] != null ? ((Number) row[2]).doubleValue() : null,
                        row[3] != null ? ((Number) row[3]).doubleValue() : null,
                        row[4] != null ? ((Number) row[4]).doubleValue() : null,
                        row[5] != null ? ((Number) row[5]).longValue() : 0L
                ))
                .toList();
    }
}

