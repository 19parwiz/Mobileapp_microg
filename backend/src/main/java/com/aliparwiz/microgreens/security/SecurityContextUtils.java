package com.aliparwiz.microgreens.security;

import com.aliparwiz.microgreens.exception.UnauthorizedException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

/**
 * Reads the authenticated user id from the JWT-backed security context.
 * The JWT subject and {@link JwtAuthenticationFilter} details hold the stable user id;
 * the principal "name" is the email at token issue time and becomes stale after profile email updates.
 */
public final class SecurityContextUtils {

    private SecurityContextUtils() {}

    public static Long getCurrentUserId() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()) {
            return null;
        }
        if (auth instanceof UsernamePasswordAuthenticationToken token && token.getDetails() instanceof Long id) {
            return id;
        }
        return null;
    }

    public static Long requireCurrentUserId() {
        Long id = getCurrentUserId();
        if (id == null) {
            throw new UnauthorizedException("Not authenticated");
        }
        return id;
    }
}
