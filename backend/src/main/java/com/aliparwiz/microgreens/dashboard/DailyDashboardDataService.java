package com.aliparwiz.microgreens.dashboard;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.BufferedWriter;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class DailyDashboardDataService {
    private final DailyDashboardDataRepository repository;

    @Value("${app.dashboard.export-dir:/data/exports}")
    private String exportDir;

    @Transactional
    public DailyDashboardData save(DailyDashboardData data) {
        if (data.getTimestamp() == null) {
            data.setTimestamp(LocalDateTime.now());
        }
        if (data.getDate() == null) {
            data.setDate(data.getTimestamp().toLocalDate());
        }
        return repository.save(data);
    }

    @Transactional
    public List<DailyDashboardData> saveAll(List<DailyDashboardData> dataList) {
        dataList.forEach(this::normalize);
        return repository.saveAll(dataList);
    }

    public List<DailyDashboardData> getByDate(LocalDate date) {
        return repository.findByDateOrderByTimestampAsc(date);
    }

    public String exportDayToCsv(LocalDate date) {
        LocalDateTime start = date.atStartOfDay();
        LocalDateTime end = date.plusDays(1).atStartOfDay();
        List<DailyDashboardData> rows = repository.findByTimestampBetweenOrderByTimestampAsc(start, end);
        if (rows.isEmpty()) {
            log.info("No dashboard rows for {}, skipping CSV export", date);
            return null;
        }

        Path dir = resolveExportDir();
        Path csv = dir.resolve("dashboard-data-" + date + ".csv");
        try (BufferedWriter writer = Files.newBufferedWriter(csv, StandardCharsets.UTF_8)) {
            writer.write("timestamp,camera_info,light_level,temperature,pH_level,substrate_moisture,humidity,ec_tds,co2_level,water_quality");
            writer.newLine();
            for (DailyDashboardData data : rows) {
                writer.write(String.join(",",
                        csvSafe(data.getTimestamp()),
                        csvSafe(data.getCameraInfo()),
                        csvSafe(data.getLightLevel()),
                        csvSafe(data.getTemperature()),
                        csvSafe(data.getPhLevel()),
                        csvSafe(data.getSubstrateMoisture()),
                        csvSafe(data.getHumidity()),
                        csvSafe(data.getEcTds()),
                        csvSafe(data.getCo2Level()),
                        csvSafe(data.getWaterQuality())
                ));
                writer.newLine();
            }
        } catch (IOException e) {
            throw new RuntimeException("Failed to export dashboard CSV for " + date, e);
        }
        return csv.toAbsolutePath().toString();
    }

    @Transactional
    public String archiveYesterdayToCsv() {
        LocalDate yesterday = LocalDate.now().minusDays(1);
        return exportDayToCsv(yesterday);
    }

    private void normalize(DailyDashboardData data) {
        if (data.getTimestamp() == null) {
            data.setTimestamp(LocalDateTime.now());
        }
        if (data.getDate() == null) {
            data.setDate(data.getTimestamp().toLocalDate());
        }
    }

    private Path resolveExportDir() {
        Path preferred = Paths.get(exportDir);
        try {
            Files.createDirectories(preferred);
            return preferred;
        } catch (IOException ex) {
            Path fallback = Paths.get("data", "exports");
            try {
                Files.createDirectories(fallback);
                return fallback;
            } catch (IOException fallbackEx) {
                throw new RuntimeException("Could not create export directory", fallbackEx);
            }
        }
    }

    private String csvSafe(Object value) {
        if (value == null) return "";
        String raw = String.valueOf(value);
        String escaped = raw.replace("\"", "\"\"");
        return "\"" + escaped + "\"";
    }
}

