package com.aliparwiz.microgreens.ai.dto;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PredictionRequest {

    @NotNull(message = "Device ID is required")
    private Long deviceId;

    private String imageBase64;

    private String predictionType;

    private String predictionData;

    private Double confidence;

    private String modelVersion;
}
