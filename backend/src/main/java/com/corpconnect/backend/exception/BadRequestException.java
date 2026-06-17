package com.corpconnect.backend.exception;

/**
 * Thrown when the request is invalid (e.g. business rule violation).
 * Handled by GlobalExceptionHandler to return 400 Bad Request.
 */
public class BadRequestException extends RuntimeException {

    public BadRequestException(String message) {
        super(message);
    }
}
