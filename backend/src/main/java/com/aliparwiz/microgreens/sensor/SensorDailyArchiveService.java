package com.aliparwiz.microgreens.sensor;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class SensorDailyArchiveService {
    private final SensorRepository sensorRepository;
    private final SensorDailyArchiveRepository dailyArchiveRepository;

    @Transactional
    public List<SensorDailyArchive> archiveDay(LocalDate date) {
        LocalDateTime start = date.atStartOfDay();
        LocalDateTime end = date.plusDays(1).atStartOfDay();

        final List<SensorReading> dayReadings =
                sensorRepository.findByTimestampBetweenOrderByTimestampAsc(start, end);
        if (dayReadings.isEmpty()) {
            log.info("[SENSOR] No readings found for {}, archive skipped", date);
            return List.of();
        }

        String csvPath = exportDailyReadingsToCsv(date, dayReadings);
        List<Object[]> aggregates = sensorRepository.findDailyAggregatesBetween(start, end);
        List<SensorDailyArchive> saved = new ArrayList<>();
        LocalDateTime now = LocalDateTime.now();

        for (Object[] row : aggregates) {
            final String deviceId = (String) row[0];
            final String sensorType = (String) row[1];
            final Double avg = row[2] != null ? ((Number) row[2]).doubleValue() : null;
            final Double min = row[3] != null ? ((Number) row[3]).doubleValue() : null;
            final Double max = row[4] != null ? ((Number) row[4]).doubleValue() : null;
            final Long count = row[5] != null ? ((Number) row[5]).longValue() : 0L;

            SensorDailyArchive archive = dailyArchiveRepository
                    .findByRecordDateAndDeviceIdAndSensorType(date, deviceId, sensorType)
                    .orElseGet(SensorDailyArchive::new);
            archive.setRecordDate(date);
            archive.setDeviceId(deviceId);
            archive.setSensorType(sensorType);
            archive.setAverageValue(avg);
            archive.setMinValue(min);
            archive.setMaxValue(max);
            archive.setSamplesCount(count);
            archive.setCsvFilePath(csvPath);
            archive.setArchivedAt(now);
            saved.add(dailyArchiveRepository.save(archive));
        }

        log.info("[SENSOR] Archived {} daily summary rows for {}", saved.size(), date);
        return saved;
    }

    public List<SensorDailyArchive> getArchiveForDay(LocalDate date) {
        return dailyArchiveRepository.findByRecordDateOrderByDeviceIdAscSensorTypeAsc(date);
    }

    private String exportDailyReadingsToCsv(LocalDate date, List<SensorReading> readings) {
        try {
            Path dir = Paths.get("exports", "sensor-daily");
            Files.createDirectories(dir);

            Path file = dir.resolve("sensor-readings-" + date + ".csv");
            List<String> lines = new ArrayList<>();
            lines.add("timestamp,device_id,sensor_type,value,unit");
            for (SensorReading reading : readings) {
                String deviceId = reading.getDevice() != null ? reading.getDevice().getDeviceId() : "";
                lines.add(String.format(
                        "%s,%s,%s,%s,%s",
                        safe(reading.getTimestamp()),
                        safe(deviceId),
                        safe(reading.getSensorType()),
                        safe(reading.getValue()),
                        safe(reading.getUnit())
                ));
            }
            Files.write(file, lines, StandardCharsets.UTF_8);
            return file.toAbsolutePath().toString();
        } catch (IOException e) {
            throw new RuntimeException("Failed to export daily sensor CSV: " + e.getMessage(), e);
        }
    }

    private String safe(Object value) {
        if (value == null) return "";
        return String.valueOf(value).replace(",", " ");
    }
}

