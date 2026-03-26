package com.aliparwiz.microgreens.dashboard;

import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/dashboard")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class DailyDashboardDataController {
    private final DailyDashboardDataService service;

    @PostMapping("/daily-data")
    public ResponseEntity<DailyDashboardData> save(@RequestBody DailyDashboardData data) {
        return ResponseEntity.ok(service.save(data));
    }

    @PostMapping("/daily-data/batch")
    public ResponseEntity<List<DailyDashboardData>> saveAll(@RequestBody List<DailyDashboardData> dataList) {
        return ResponseEntity.ok(service.saveAll(dataList));
    }

    @GetMapping("/daily-data/{date}")
    public ResponseEntity<List<DailyDashboardData>> getByDate(
            @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        return ResponseEntity.ok(service.getByDate(date));
    }

    @PostMapping("/daily-data/export/{date}")
    public ResponseEntity<?> exportByDate(
            @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        String path = service.exportDayToCsv(date);
        return ResponseEntity.ok(Map.of(
                "date", date.toString(),
                "csvPath", path == null ? "" : path
        ));
    }
}

