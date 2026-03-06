package com.aliparwiz.microgreens.admin.dto;

import com.aliparwiz.microgreens.device.Device;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Device Response DTO - Safe representation of Device with owner info
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@JsonInclude(JsonInclude.Include.NON_NULL)
public class DeviceResponseDto {
    
    private Long id;
    private String name;
    private String deviceId;
    private String description;
    private String deviceType;
    private String location;
    private Boolean isActive;
    private LocalDateTime lastSeen;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Long ownerId;
    private String ownerEmail;
    private String ownerName;

    public static DeviceResponseDto fromDevice(Device device) {
        return DeviceResponseDto.builder()
            .id(device.getId())
            .name(device.getName())
            .deviceId(device.getDeviceId())
            .description(device.getDescription())
            .deviceType(device.getDeviceType())
            .location(device.getLocation())
            .isActive(device.getIsActive())
            .lastSeen(device.getLastSeen())
            .createdAt(device.getCreatedAt())
            .updatedAt(device.getUpdatedAt())
            .ownerId(device.getOwner() != null ? device.getOwner().getId() : null)
            .ownerEmail(device.getOwner() != null ? device.getOwner().getEmail() : null)
            .ownerName(device.getOwner() != null ? device.getOwner().getName() : null)
            .build();
    }
}
