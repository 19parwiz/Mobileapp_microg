package com.aliparwiz.microgreens.sensor;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SensorRepository extends JpaRepository<SensorReading, Long> {
    List<SensorReading> findByDevice_DeviceId(String deviceId);
    List<SensorReading> findByDevice_DeviceIdAndSensorType(String deviceId, String sensorType);
    
    @Query("SELECT sr FROM SensorReading sr WHERE sr.device.deviceId = :deviceId ORDER BY sr.timestamp DESC")
    List<SensorReading> findLatestByDeviceId(@Param("deviceId") String deviceId);
    
    @Query("SELECT sr FROM SensorReading sr WHERE sr.device.deviceId = :deviceId AND sr.sensorType = :sensorType ORDER BY sr.timestamp DESC")
    Optional<SensorReading> findLatestByDeviceIdAndSensorType(
            @Param("deviceId") String deviceId,
            @Param("sensorType") String sensorType);
}

