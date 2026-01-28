package com.aliparwiz.microgreens.exception;

/**
 * Exception thrown when invalid data is provided
 */
public class ValidationException extends RuntimeException {
    public ValidationException(String message) {
        super(message);
    }

    public ValidationException(String message, Throwable cause) {
        super(message, cause);
    }
}
