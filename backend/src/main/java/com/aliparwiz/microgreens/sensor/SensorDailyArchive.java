package com.aliparwiz.microgreens.sensor;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(
        name = "sensor_daily_archives",
        uniqueConstraints = @UniqueConstraint(
                name = "uk_sensor_daily_archive",
                columnNames = {"record_date", "device_id", "sensor_type"}
        )
)
@Data
@NoArgsConstructor
@AllArgsConstructor
public class SensorDailyArchive {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "record_date", nullable = false)
    private LocalDate recordDate;

    @Column(name = "device_id", nullable = false, length = 100)
    private String deviceId;

    @Column(name = "sensor_type", nullable = false, length = 100)
    private String sensorType;

    @Column(name = "average_value")
    private Double averageValue;

    @Column(name = "min_value")
    private Double minValue;

    @Column(name = "max_value")
    private Double maxValue;

    @Column(name = "samples_count", nullable = false)
    private Long samplesCount;

    @Column(name = "csv_file_path")
    private String csvFilePath;

    @Column(name = "archived_at", nullable = false)
    private LocalDateTime archivedAt;
}

