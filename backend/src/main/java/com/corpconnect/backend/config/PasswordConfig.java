package com.corpconnect.backend.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

/**
 * Configuration class for password encoding.
 * 
 * BCrypt is used for password hashing because:
 * - It's an adaptive hashing algorithm that automatically handles salt generation
 * - The computational cost can be adjusted to keep up with increasing hardware capabilities
 * - It's resistant to rainbow table attacks due to built-in salting
 * - It's a proven, industry-standard algorithm widely used in production systems
 * - Each password hash includes a unique salt, preventing identical passwords from having the same hash
 */
@Configuration
public class PasswordConfig {

    /**
     * Provides a BCryptPasswordEncoder bean for password encoding and verification.
     * 
     * @return PasswordEncoder instance using BCrypt algorithm
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}

