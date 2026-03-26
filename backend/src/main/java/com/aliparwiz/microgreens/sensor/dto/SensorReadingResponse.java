package com.aliparwiz.microgreens.sensor.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SensorReadingResponse {

    private Long id;
    private String sensorType;
    private Double value;
    private String unit;
    private LocalDateTime timestamp;
}
