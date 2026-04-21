package com.aliparwiz.microgreens.device;

import com.aliparwiz.microgreens.config.SecurityConfig;
import com.aliparwiz.microgreens.device.dto.DeviceResponse;
import com.aliparwiz.microgreens.security.JwtAuthenticationFilter;
import com.aliparwiz.microgreens.security.JwtTokenProvider;
import com.aliparwiz.microgreens.testsupport.EnableTestLifecycleLogging;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@EnableTestLifecycleLogging
@WebMvcTest(controllers = DeviceController.class)
@Import({SecurityConfig.class, JwtAuthenticationFilter.class})
class DeviceControllerSecurityWebMvcTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private DeviceService deviceService;

    // We mock token provider so the JWT filter can be created without real secrets.
    @MockBean
    private JwtTokenProvider jwtTokenProvider;

    @Test
    @DisplayName("GET /api/devices returns 403 when request has no auth")
    void getDevicesShouldReturnForbiddenWithoutAuth() throws Exception {
        mockMvc.perform(get("/api/devices").accept(MediaType.APPLICATION_JSON))
                .andExpect(status().isForbidden());
    }

    @Test
    @WithMockUser(username = "user@example.com", roles = {"USER"})
    @DisplayName("GET /api/devices returns 200 for authenticated user")
    void getDevicesShouldReturnOkForAuthenticatedUser() throws Exception {
        DeviceResponse response = DeviceResponse.builder()
                .id(1L)
                .name("Grow Box")
                .deviceId("dev-1")
                .deviceType("sensor")
                .build();
        when(deviceService.getAllDevices()).thenReturn(List.of(response));

        mockMvc.perform(get("/api/devices").accept(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].deviceId").value("dev-1"));
    }
}
