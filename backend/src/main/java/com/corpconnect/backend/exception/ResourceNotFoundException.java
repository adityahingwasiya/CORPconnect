package com.corpconnect.backend.exception;

/**
 * Thrown when a requested resource is not found (e.g. company or employee
 * not found by ID/email). Handled by GlobalExceptionHandler to return
 * 404 Not Found.
 */
public class ResourceNotFoundException extends RuntimeException {

    public ResourceNotFoundException(String message) {
        super(message);
    }
}
