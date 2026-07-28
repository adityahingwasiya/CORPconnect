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
      registers a new company
      @param request The registration request containing company details
      @return the saved company entity
      @throws runtimeException if the email already exists
     */
    public Company registerCompany(CompanyRegisterRequest request) {
        // check if email exists already
        if (companyRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new DuplicateResourceException("Email already exists");
        }

        // encode password using passwordencoder
        String encodedPassword = passwordEncoder.encode(request.getPassword());

        // creating and saving company
        Company company = new Company();
        company.setName(request.getName());
        company.setEmail(request.getEmail());
        company.setPasswordHash(encodedPassword);

        //return saved company
        return companyRepository.save(company);
    }

    /**
      Authenticates a company admin for login 
      @param request The login request containing email and password
      @return The authenticated company entity
      @throws runtimeException if email is not found
     */
    public Company loginCompany(LoginRequest request) {
        // fetch company by email
        Company company = companyRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new AuthenticationFailedException("Invalid email or password"));

        // match password using passwordencoder match function
        if (!passwordEncoder.matches(request.getPassword(), company.getPasswordHash())) {
            throw new AuthenticationFailedException("Invalid email or password");
        }

        // return company
        return company;
    }
}

