package com.aliparwiz.microgreens.device;

import com.aliparwiz.microgreens.auth.AuthRepository;
import com.aliparwiz.microgreens.auth.User;
import com.aliparwiz.microgreens.testsupport.EnableTestLifecycleLogging;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.when;

@EnableTestLifecycleLogging
@ExtendWith(MockitoExtension.class)
class DeviceServiceSecurityTest {

    @Mock
    private DeviceRepository deviceRepository;

    @Mock
    private AuthRepository authRepository;

    @InjectMocks
    private DeviceService deviceService;

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    @Test
    @DisplayName("Owner can fetch device by external deviceId")
    void ownerCanFetchDeviceByExternalId() {
        setAuthenticatedUser("owner@example.com", "ROLE_USER");

        User owner = new User();
        owner.setId(10L);
        owner.setEmail("owner@example.com");
        when(authRepository.findByEmail("owner@example.com")).thenReturn(Optional.of(owner));

        Device device = new Device();
        device.setId(77L);
        device.setDeviceId("dev-77");
        device.setOwner(owner);
        when(deviceRepository.findByDeviceId("dev-77")).thenReturn(Optional.of(device));

        assertDoesNotThrow(() -> deviceService.getDeviceByDeviceId("dev-77"));
    }

    @Test
    @DisplayName("Non-owner is blocked when requesting another user's device")
    void nonOwnerCannotFetchDeviceByExternalId() {
        setAuthenticatedUser("guest@example.com", "ROLE_USER");

        User requester = new User();
        requester.setId(20L);
        requester.setEmail("guest@example.com");
        when(authRepository.findByEmail("guest@example.com")).thenReturn(Optional.of(requester));

        User owner = new User();
        owner.setId(99L);

        Device device = new Device();
        device.setDeviceId("dev-private");
        device.setOwner(owner);
        when(deviceRepository.findByDeviceId("dev-private")).thenReturn(Optional.of(device));

        RuntimeException ex = assertThrows(
                RuntimeException.class,
                () -> deviceService.getDeviceByDeviceId("dev-private")
        );
        assertEquals("Access denied: This device does not belong to you", ex.getMessage());
    }

    @Test
    @DisplayName("Admin can fetch any device by external deviceId")
    void adminCanFetchAnyDeviceByExternalId() {
        setAuthenticatedUser("admin@example.com", "ROLE_ADMIN");

        User owner = new User();
        owner.setId(35L);
        Device device = new Device();
        device.setDeviceId("dev-admin-visible");
        device.setOwner(owner);
        when(deviceRepository.findByDeviceId("dev-admin-visible")).thenReturn(Optional.of(device));

        assertDoesNotThrow(() -> deviceService.getDeviceByDeviceId("dev-admin-visible"));
    }

    private void setAuthenticatedUser(String email, String role) {
        UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(
                email,
                null,
                List.of(new SimpleGrantedAuthority(role))
        );
        SecurityContextHolder.getContext().setAuthentication(authentication);
    }
}
