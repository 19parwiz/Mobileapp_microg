package com.aliparwiz.microgreens.device;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class DeviceService {
    
    private final DeviceRepository deviceRepository;
    
    public List<Device> getAllDevices() {
        return deviceRepository.findAll();
    }
    
    public Device getDeviceById(Long id) {
        return deviceRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Device not found"));
    }
    
    public Device getDeviceByDeviceId(String deviceId) {
        return deviceRepository.findByDeviceId(deviceId)
            .orElseThrow(() -> new RuntimeException("Device not found"));
    }
    
    @Transactional
    public Device createDevice(Device device) {
        if (device.getDeviceId() != null && deviceRepository.existsByDeviceId(device.getDeviceId())) {
            throw new RuntimeException("Device with this ID already exists");
        }
        device.setCreatedAt(LocalDateTime.now());
        device.setUpdatedAt(LocalDateTime.now());
        return deviceRepository.save(device);
    }
    
    @Transactional
    public Device updateDevice(Long id, Device deviceDetails) {
        Device device = getDeviceById(id);
        
        if (deviceDetails.getName() != null) {
            device.setName(deviceDetails.getName());
        }
        if (deviceDetails.getDescription() != null) {
            device.setDescription(deviceDetails.getDescription());
        }
        if (deviceDetails.getDeviceType() != null) {
            device.setDeviceType(deviceDetails.getDeviceType());
        }
        if (deviceDetails.getLocation() != null) {
            device.setLocation(deviceDetails.getLocation());
        }
        if (deviceDetails.getIsActive() != null) {
            device.setIsActive(deviceDetails.getIsActive());
        }
        
        device.setUpdatedAt(LocalDateTime.now());
        return deviceRepository.save(device);
    }
    
    @Transactional
    public void deleteDevice(Long id) {
        Device device = getDeviceById(id);
        deviceRepository.delete(device);
    }
    
    @Transactional
    public void updateLastSeen(String deviceId) {
        Device device = deviceRepository.findByDeviceId(deviceId)
            .orElse(null);
        if (device != null) {
            device.setLastSeen(LocalDateTime.now());
            deviceRepository.save(device);
        }
    }
}

