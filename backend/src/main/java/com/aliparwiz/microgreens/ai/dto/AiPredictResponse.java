package com.aliparwiz.microgreens.ai.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AiPredictResponse {

    private String filename;
    private List<String> predictions;
    private String topPrediction;
    private String message;
}
