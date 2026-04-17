package com.aliparwiz.microgreens.exception;

/**
 * Valid credentials but account is not email-verified yet.
 */
public class EmailNotVerifiedException extends RuntimeException {

    public EmailNotVerifiedException(String message) {
        super(message);
    }
}
