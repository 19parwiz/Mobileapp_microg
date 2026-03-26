package com.aliparwiz.microgreens.dashboard;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "daily_dashboard_data")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DailyDashboardData {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private LocalDate date;

    @Column(nullable = false)
    private LocalDateTime timestamp;

    @Column(name = "camera_info", columnDefinition = "TEXT")
    private String cameraInfo;

    @Column(name = "light_level")
    private Integer lightLevel;

    private Double temperature;

    @Column(name = "ph_level")
    private Double phLevel;

    @Column(name = "substrate_moisture")
    private Double substrateMoisture;

    private Double humidity;

    @Column(name = "ec_tds")
    private Double ecTds;

    @Column(name = "co2_level")
    private Double co2Level;

    @Column(name = "water_quality", columnDefinition = "TEXT")
    private String waterQuality;
}

