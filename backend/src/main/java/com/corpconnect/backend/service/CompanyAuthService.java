package com.corpconnect.backend.service;

import com.corpconnect.backend.dto.auth.CompanyRegisterRequest;
import com.corpconnect.backend.dto.auth.LoginRequest;
import com.corpconnect.backend.entity.Company;
import com.corpconnect.backend.exception.AuthenticationFailedException;
import com.corpconnect.backend.exception.DuplicateResourceException;
import com.corpconnect.backend.repository.CompanyRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class CompanyAuthService {

    private final CompanyRepository companyRepository;
    private final PasswordEncoder passwordEncoder;

    public CompanyAuthService(CompanyRepository companyRepository, PasswordEncoder passwordEncoder) {
        this.companyRepository = companyRepository;
        this.passwordEncoder = passwordEncoder;
    }

    /**
     * Registers a new company.
     * 
     * @param request The registration request containing company details
     * @return The saved Company entity
     * @throws RuntimeException if the email already exists
     */
    public Company registerCompany(CompanyRegisterRequest request) {
        // Check if email already exists
        if (companyRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new DuplicateResourceException("Email already exists");
        }

        // Encode password using PasswordEncoder
        String encodedPassword = passwordEncoder.encode(request.getPassword());

        // Create and save Company
        Company company = new Company();
        company.setName(request.getName());
        company.setEmail(request.getEmail());
        company.setPasswordHash(encodedPassword);

        // Return saved Company
        return companyRepository.save(company);
    }

    /**
     * Authenticates a company admin for login.
     * 
     * @param request The login request containing email and password
     * @return The authenticated Company entity
     * @throws RuntimeException if email is not found or password is invalid
     */
    public Company loginCompany(LoginRequest request) {
        // Fetch company by email
        Company company = companyRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new AuthenticationFailedException("Invalid email or password"));

        // Match password using PasswordEncoder.matches()
        if (!passwordEncoder.matches(request.getPassword(), company.getPasswordHash())) {
            throw new AuthenticationFailedException("Invalid email or password");
        }

        // Return Company
        return company;
    }
}

