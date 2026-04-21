package com.aliparwiz.microgreens.admin;

import com.aliparwiz.microgreens.auth.AuthRepository;
import com.aliparwiz.microgreens.auth.User;
import com.aliparwiz.microgreens.config.SecurityConfig;
import com.aliparwiz.microgreens.device.DeviceRepository;
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
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@EnableTestLifecycleLogging
@WebMvcTest(controllers = AdminController.class)
@Import({SecurityConfig.class, JwtAuthenticationFilter.class})
class AdminControllerSecurityWebMvcTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private AuthRepository authRepository;

    @MockBean
    private DeviceRepository deviceRepository;

    // Keeps the filter wiring lightweight inside this controller-only test.
    @MockBean
    private JwtTokenProvider jwtTokenProvider;

    @Test
    @DisplayName("GET /api/admin/users returns 403 when unauthenticated")
    void adminEndpointShouldReturnForbiddenWithoutAuth() throws Exception {
        mockMvc.perform(get("/api/admin/users").accept(MediaType.APPLICATION_JSON))
                .andExpect(status().isForbidden());
    }

    @Test
    @WithMockUser(username = "user@example.com", roles = {"USER"})
    @DisplayName("GET /api/admin/users returns 403 for non-admin user")
    void adminEndpointShouldReturnForbiddenForNormalUser() throws Exception {
        mockMvc.perform(get("/api/admin/users").accept(MediaType.APPLICATION_JSON))
                .andExpect(status().isForbidden());
    }

    @Test
    @WithMockUser(username = "admin@example.com", roles = {"ADMIN"})
    @DisplayName("GET /api/admin/users returns 200 for admin")
    void adminEndpointShouldReturnOkForAdmin() throws Exception {
        when(authRepository.findAll()).thenReturn(List.of(new User()));

        mockMvc.perform(get("/api/admin/users").accept(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk());
    }
}
