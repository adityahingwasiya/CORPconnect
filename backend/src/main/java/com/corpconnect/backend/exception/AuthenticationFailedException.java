package com.corpconnect.backend.exception;

/**
 * Thrown when authentication fails (invalid email or password).
 * Handled by GlobalExceptionHandler to return 401 Unauthorized.
 */
public class AuthenticationFailedException extends RuntimeException {

    public AuthenticationFailedException(String message) {
        super(message);
    }
}
