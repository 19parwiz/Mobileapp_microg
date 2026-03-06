package com.aliparwiz.microgreens.sensor;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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
    
    public List<SensorReading> getLatestReadingsByDeviceId(String deviceId) {
        return sensorRepository.findLatestByDeviceId(deviceId);
    }
    
    public Optional<SensorReading> getLatestReadingByDeviceIdAndSensorType(String deviceId, String sensorType) {
        return sensorRepository.findLatestByDeviceIdAndSensorType(deviceId, sensorType);
    }
    
    public List<SensorReading> getAllReadings() {
        return sensorRepository.findAll();
    }
}

