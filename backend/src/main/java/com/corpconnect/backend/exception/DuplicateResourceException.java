package com.corpconnect.backend.exception;

/**
 * Thrown when attempting to create a resource that already exists
 * (e.g. duplicate email). Handled by GlobalExceptionHandler to return
 * 409 Conflict.
 */
public class DuplicateResourceException extends RuntimeException {

    public DuplicateResourceException(String message) {
        super(message);
    }
}
