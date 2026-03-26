package com.aliparwiz.microgreens.sensor;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDate;

@Slf4j
@Component
@RequiredArgsConstructor
public class SensorDailyArchiveScheduler {
    private final SensorDailyArchiveService dailyArchiveService;

    // Run every day at 00:05 and archive the previous day.
    @Scheduled(cron = "0 5 0 * * *")
    public void archiveYesterday() {
        LocalDate yesterday = LocalDate.now().minusDays(1);
        try {
            dailyArchiveService.archiveDay(yesterday);
        } catch (Exception e) {
            log.error("Daily sensor archive job failed for {}", yesterday, e);
        }
    }
}

