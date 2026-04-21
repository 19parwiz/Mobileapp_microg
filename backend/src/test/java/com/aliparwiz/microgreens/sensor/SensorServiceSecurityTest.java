package com.aliparwiz.microgreens.sensor;

import com.aliparwiz.microgreens.auth.User;
import com.aliparwiz.microgreens.device.Device;
import com.aliparwiz.microgreens.device.DeviceRepository;
import com.aliparwiz.microgreens.testsupport.EnableTestLifecycleLogging;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.Collections;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@EnableTestLifecycleLogging
@ExtendWith(MockitoExtension.class)
class SensorServiceSecurityTest {

    @Mock
    private SensorRepository sensorRepository;

    @Mock
    private DeviceRepository deviceRepository;

    @InjectMocks
    private SensorService sensorService;

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    @Test
    @DisplayName("Owner can read sensor data for own device")
    void ownerCanReadSensorData() {
        setAuthenticatedUser(10L, "ROLE_USER");

        Device ownedDevice = buildDevice("dev-10", 10L);
        when(deviceRepository.findByDeviceId("dev-10")).thenReturn(Optional.of(ownedDevice));
        when(sensorRepository.findByDevice_DeviceId("dev-10")).thenReturn(Collections.emptyList());

        assertDoesNotThrow(() -> sensorService.getReadingsByDeviceId("dev-10"));
        verify(sensorRepository).findByDevice_DeviceId("dev-10");
    }

    @Test
    @DisplayName("Non-owner cannot read sensor data from someone else's device")
    void nonOwnerCannotReadSensorData() {
        setAuthenticatedUser(10L, "ROLE_USER");

        Device someoneElseDevice = buildDevice("dev-99", 99L);
        when(deviceRepository.findByDeviceId("dev-99")).thenReturn(Optional.of(someoneElseDevice));

        assertThrows(AccessDeniedException.class, () -> sensorService.getReadingsByDeviceId("dev-99"));
    }

    @Test
    @DisplayName("Only admins can call the global sensor list endpoint")
    void onlyAdminCanGetAllReadings() {
        setAuthenticatedUser(10L, "ROLE_USER");
        assertThrows(AccessDeniedException.class, () -> sensorService.getAllReadings());

        setAuthenticatedUser(1L, "ROLE_ADMIN");
        when(sensorRepository.findAll()).thenReturn(List.of());
        assertDoesNotThrow(() -> sensorService.getAllReadings());
    }

    private static Device buildDevice(String deviceId, Long ownerId) {
        User owner = new User();
        owner.setId(ownerId);
        Device device = new Device();
        device.setDeviceId(deviceId);
        device.setOwner(owner);
        return device;
    }

    private void setAuthenticatedUser(Long userId, String role) {
        UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(
                "user@example.com",
                null,
                List.of(new SimpleGrantedAuthority(role))
        );
        // SecurityContextUtils reads current user id from token details.
        authentication.setDetails(userId);
        SecurityContextHolder.getContext().setAuthentication(authentication);
    }
}
