package com.aliparwiz.microgreens.ai.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PredictionResponse {

    private Long id;
    private String prediction;
    private Double confidence;
    private String message;
    private String modelVersion;
    private LocalDateTime timestamp;

    @JsonProperty("predictionType")
    public String getPredictionType() {
        return message;
    }

    @JsonProperty("predictionData")
    public String getPredictionData() {
        return prediction;
    }

    @JsonProperty("confidenceScore")
    public Double getConfidenceScore() {
        return confidence;
    }
}
