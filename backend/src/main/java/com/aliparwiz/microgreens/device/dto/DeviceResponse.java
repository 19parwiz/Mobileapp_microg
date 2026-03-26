package com.aliparwiz.microgreens.device.dto;

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
public class DeviceResponse {

    private Long id;
    private String name;
    private String deviceId;
    private String description;
    private String deviceType;
    private String location;
    private Boolean isActive;
    private LocalDateTime lastSeen;
    private LocalDateTime createdAt;

    @JsonProperty("type")
    public String getType() {
        return deviceType;
    }
}
