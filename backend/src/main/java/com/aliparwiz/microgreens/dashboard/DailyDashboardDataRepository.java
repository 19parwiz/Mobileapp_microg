package com.aliparwiz.microgreens.dashboard;

import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

public interface DailyDashboardDataRepository extends JpaRepository<DailyDashboardData, Long> {
    List<DailyDashboardData> findByDateOrderByTimestampAsc(LocalDate date);
    List<DailyDashboardData> findByTimestampBetweenOrderByTimestampAsc(LocalDateTime start, LocalDateTime end);
}

