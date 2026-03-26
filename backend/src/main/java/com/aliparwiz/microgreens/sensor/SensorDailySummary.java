package com.aliparwiz.microgreens.sensor;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SensorDailySummary {
    private LocalDate date;
    private String sensorType;
    private Double averageValue;
    private Double minValue;
    private Double maxValue;
    private Long samplesCount;
}

