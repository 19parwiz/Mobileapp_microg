package com.aliparwiz.microgreens.auth;

import com.aliparwiz.microgreens.device.Device;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.ToString;

import java.time.LocalDateTime;
import java.util.List;

/**
 * User Entity
 * Represents a user account in the system
 */
@Entity
@Table(
    name = "users",
    indexes = {
        @Index(name = "idx_users_verification_token", columnList = "verification_token", unique = true),
        @Index(name = "idx_users_reset_password_token", columnList = "reset_password_token")
    }
)
@Data
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(exclude = {"devices"})
@ToString(exclude = {"devices"})
public class User {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(unique = true, nullable = false)
    private String email;
    
    @Column(nullable = false)
    private String password;
    
    private String name;
    
    @Enumerated(EnumType.STRING)
    private Role role = Role.USER;

    /**
     * Null means legacy row (treated as ACTIVE for login). New registrations use PENDING_VERIFICATION until verified.
     */
    @Enumerated(EnumType.STRING)
    @Column(name = "account_status", length = 32)
    private AccountStatus accountStatus;

    @Column(name = "verification_token", unique = true, length = 64)
    private String verificationToken;

    @Column(name = "reset_password_token", length = 64)
    private String resetPasswordToken;

    @Column(name = "reset_password_expiry")
    private LocalDateTime resetPasswordExpiry;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt = LocalDateTime.now();
    
    // One user can have many devices
    @OneToMany(mappedBy = "owner", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    private List<Device> devices;
}

