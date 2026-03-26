package com.aliparwiz.microgreens.sensor;

import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface SensorDailyArchiveRepository extends JpaRepository<SensorDailyArchive, Long> {
    List<SensorDailyArchive> findByRecordDateOrderByDeviceIdAscSensorTypeAsc(LocalDate recordDate);
    Optional<SensorDailyArchive> findByRecordDateAndDeviceIdAndSensorType(
            LocalDate recordDate,
            String deviceId,
            String sensorType
    );
}

