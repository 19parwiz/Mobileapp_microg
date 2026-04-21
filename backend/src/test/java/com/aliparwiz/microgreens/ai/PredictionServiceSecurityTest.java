package com.aliparwiz.microgreens.ai;

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

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.when;

@EnableTestLifecycleLogging
@ExtendWith(MockitoExtension.class)
class PredictionServiceSecurityTest {

    @Mock
    private PredictionRepository predictionRepository;

    @Mock
    private DeviceRepository deviceRepository;

    @InjectMocks
    private PredictionService predictionService;

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    @Test
    @DisplayName("Owner can read predictions for own device")
    void ownerCanReadPredictions() {
        setAuthenticatedUser(25L, "ROLE_USER");
        when(deviceRepository.findByDeviceId("dev-25")).thenReturn(Optional.of(buildDevice("dev-25", 25L)));
        when(predictionRepository.findByDevice_DeviceId("dev-25")).thenReturn(List.of());

        assertDoesNotThrow(() -> predictionService.getPredictionsByDeviceId("dev-25"));
    }

    @Test
    @DisplayName("Non-owner cannot read predictions for another device")
    void nonOwnerCannotReadPredictions() {
        setAuthenticatedUser(25L, "ROLE_USER");
        when(deviceRepository.findByDeviceId("dev-40")).thenReturn(Optional.of(buildDevice("dev-40", 40L)));

        assertThrows(AccessDeniedException.class, () -> predictionService.getPredictionsByDeviceId("dev-40"));
    }

    @Test
    @DisplayName("Only admins can access the global prediction list")
    void onlyAdminCanGetAllPredictions() {
        setAuthenticatedUser(25L, "ROLE_USER");
        assertThrows(AccessDeniedException.class, () -> predictionService.getAllPredictions());

        setAuthenticatedUser(1L, "ROLE_ADMIN");
        when(predictionRepository.findAll()).thenReturn(List.of());
        assertDoesNotThrow(() -> predictionService.getAllPredictions());
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
