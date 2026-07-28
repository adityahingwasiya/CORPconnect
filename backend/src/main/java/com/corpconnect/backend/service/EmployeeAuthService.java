package com.corpconnect.backend.service;

import com.corpconnect.backend.dto.auth.LoginRequest;
import com.corpconnect.backend.entity.Employee;
import com.corpconnect.backend.exception.AuthenticationFailedException;
import com.corpconnect.backend.repository.EmployeeRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

  // service for employee authentication ope
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
      authenticates an employee for login
      @param requesting  login request containing email and password
      @return The authenticated employee entity
      @throws runtimeException if email is not found or password is invalid
     */
    public Employee loginEmployee(LoginRequest request) {
        String email = request.getEmail();

        logger.info("Attempting employee login for email: {}", email);

        // fetch employee by email
        Employee employee = employeeRepository.findByEmail(email)
                .orElseThrow(() -> {
                    logger.warn("Employee login failed - no employee found with email: {}", email);
                    return new AuthenticationFailedException("Invalid email or password");
                });

        // match password using Passwordencoder matches function
        if (!passwordEncoder.matches(request.getPassword(), employee.getPasswordHash())) {
            logger.warn("Employee login failed - password mismatch for email: {}", email);
            throw new AuthenticationFailedException("Invalid email or password");
        }

        logger.info("Employee login successful for email: {}", email);

        // Return employee
        return employee;
    }
}
