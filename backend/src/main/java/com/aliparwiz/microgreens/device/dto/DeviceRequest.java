package com.aliparwiz.microgreens.device.dto;

import com.fasterxml.jackson.annotation.JsonAlias;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DeviceRequest {

    @NotBlank(message = "Device name is required")
    @Size(max = 100, message = "Name must be at most 100 characters")
    private String name;

    @NotBlank(message = "Device ID is required")
    @Size(max = 100, message = "Device ID must be at most 100 characters")
    private String deviceId;

    private String description;

    @JsonAlias("type")
    private String deviceType;

    private String location;

    private Boolean isActive;
}
