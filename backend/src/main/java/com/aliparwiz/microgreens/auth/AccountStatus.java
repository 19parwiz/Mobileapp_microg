package com.aliparwiz.microgreens.auth;

/**
 * Account lifecycle for email verification and moderation.
 */
public enum AccountStatus {
    PENDING_VERIFICATION,
    ACTIVE,
    SUSPENDED
}
