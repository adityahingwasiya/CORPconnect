package com.corpconnect.backend.service;

import com.corpconnect.backend.dto.auth.LoginRequest;
import com.corpconnect.backend.entity.Employee;
import com.corpconnect.backend.exception.AuthenticationFailedException;
import com.corpconnect.backend.repository.EmployeeRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

/**
 * Service for employee authentication operations.
 */
@Service
public class EmployeeAuthService {

    private static final Logger logger = LoggerFactory.getLogger(EmployeeAuthService.class);

    private final EmployeeRepository employeeRepository;
    private final PasswordEncoder passwordEncoder;

    public EmployeeAuthService(EmployeeRepository employeeRepository, PasswordEncoder passwordEncoder) {
        this.employeeRepository = employeeRepository;
        this.passwordEncoder = passwordEncoder;
    }

    /**
     * Authenticates an employee for login.
     *
     * @param request The login request containing email and password
     * @return The authenticated Employee entity
     * @throws RuntimeException if email is not found or password is invalid
     */
    public Employee loginEmployee(LoginRequest request) {
        String email = request.getEmail();

        logger.info("Attempting employee login for email: {}", email);

        // Fetch employee by email
        Employee employee = employeeRepository.findByEmail(email)
                .orElseThrow(() -> {
                    logger.warn("Employee login failed - no employee found with email: {}", email);
                    return new AuthenticationFailedException("Invalid email or password");
                });

        // Match password using PasswordEncoder.matches()
        if (!passwordEncoder.matches(request.getPassword(), employee.getPasswordHash())) {
            logger.warn("Employee login failed - password mismatch for email: {}", email);
            throw new AuthenticationFailedException("Invalid email or password");
        }

        logger.info("Employee login successful for email: {}", email);

        // Return Employee
        return employee;
    }
}
