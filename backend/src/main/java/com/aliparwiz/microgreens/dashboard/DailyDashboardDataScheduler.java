package com.aliparwiz.microgreens.dashboard;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class DailyDashboardDataScheduler {
    private final DailyDashboardDataService service;

    @Scheduled(cron = "0 0 0 * * *")
    public void exportYesterday() {
        try {
            String path = service.archiveYesterdayToCsv();
            if (path != null) {
                log.info("Daily dashboard CSV exported: {}", path);
            }
        } catch (Exception e) {
            log.error("Failed daily dashboard CSV export job", e);
        }
    }
}

