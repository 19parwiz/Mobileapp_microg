package com.aliparwiz.microgreens.sensor;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface SensorRepository extends JpaRepository<SensorReading, Long> {
    List<SensorReading> findByDevice_DeviceId(String deviceId);
    List<SensorReading> findByDevice_DeviceIdAndSensorType(String deviceId, String sensorType);
    List<SensorReading> findByDevice_DeviceIdAndTimestampBetween(
            String deviceId,
            LocalDateTime start,
            LocalDateTime end
    );
    List<SensorReading> findByTimestampBetweenOrderByTimestampAsc(LocalDateTime start, LocalDateTime end);
    
    @Query("SELECT sr FROM SensorReading sr WHERE sr.device.deviceId = :deviceId ORDER BY sr.timestamp DESC")
    List<SensorReading> findLatestByDeviceId(@Param("deviceId") String deviceId);
    
    @Query("SELECT sr FROM SensorReading sr WHERE sr.device.deviceId = :deviceId AND sr.sensorType = :sensorType ORDER BY sr.timestamp DESC")
    Optional<SensorReading> findLatestByDeviceIdAndSensorType(
            @Param("deviceId") String deviceId,
            @Param("sensorType") String sensorType);

    @Query("""
        SELECT function('date', sr.timestamp), sr.sensorType, avg(sr.value), min(sr.value), max(sr.value), count(sr)
        FROM SensorReading sr
        WHERE sr.device.deviceId = :deviceId
        GROUP BY function('date', sr.timestamp), sr.sensorType
        ORDER BY function('date', sr.timestamp) DESC
    """)
    List<Object[]> findDailySummariesByDeviceId(@Param("deviceId") String deviceId);

    @Query("""
        SELECT sr.device.deviceId, sr.sensorType, avg(sr.value), min(sr.value), max(sr.value), count(sr)
        FROM SensorReading sr
        WHERE sr.timestamp >= :start AND sr.timestamp < :end
        GROUP BY sr.device.deviceId, sr.sensorType
        ORDER BY sr.device.deviceId, sr.sensorType
    """)
    List<Object[]> findDailyAggregatesBetween(
            @Param("start") LocalDateTime start,
            @Param("end") LocalDateTime end
    );
}

