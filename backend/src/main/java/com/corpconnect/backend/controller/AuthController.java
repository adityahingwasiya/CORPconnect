package com.corpconnect.backend.controller;

import com.corpconnect.backend.dto.auth.AuthResponse;
import com.corpconnect.backend.dto.auth.CompanyRegisterRequest;
import com.corpconnect.backend.dto.auth.LoginRequest;
import com.corpconnect.backend.entity.Company;
import com.corpconnect.backend.entity.Employee;
import com.corpconnect.backend.security.JwtUtil;
import com.corpconnect.backend.service.CompanyAuthService;
import com.corpconnect.backend.service.EmployeeAuthService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final CompanyAuthService companyAuthService;
    private final EmployeeAuthService employeeAuthService;
    private final JwtUtil jwtUtil;

    public AuthController(CompanyAuthService companyAuthService, 
                         EmployeeAuthService employeeAuthService,
                         JwtUtil jwtUtil) {
        this.companyAuthService = companyAuthService;
        this.employeeAuthService = employeeAuthService;
        this.jwtUtil = jwtUtil;
    }

    @PostMapping("/company/register")
    public ResponseEntity<Map<String, Object>> registerCompany(@Valid @RequestBody CompanyRegisterRequest request) {
        var company = companyAuthService.registerCompany(request);
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Company registered successfully");
        response.put("companyId", company.getId());
        
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PostMapping("/company/login")
    public ResponseEntity<AuthResponse> loginCompany(@Valid @RequestBody LoginRequest request) {
        Company company = companyAuthService.loginCompany(request);
        
        // Generate JWT token
        String token = jwtUtil.generateToken(company.getEmail(), "COMPANY_ADMIN", company.getId());
        
        AuthResponse response = new AuthResponse();
        response.setToken(token);
        response.setRole("COMPANY_ADMIN");
        response.setUserId(company.getId());
        response.setCompanyName(company.getName());
        
        return ResponseEntity.ok(response);
    }

    @PostMapping("/employee/login")
    public ResponseEntity<AuthResponse> loginEmployee(@Valid @RequestBody LoginRequest request) {
        Employee employee = employeeAuthService.loginEmployee(request);
        
        // Generate JWT token with role from employee.role.name()
        String token = jwtUtil.generateToken(employee.getEmail(), employee.getRole().name(), employee.getId());
        
        AuthResponse response = new AuthResponse();
        response.setToken(token);
        response.setRole(employee.getRole().name());
        response.setUserId(employee.getId());
        response.setName(employee.getName());
        response.setEmail(employee.getEmail());
        response.setCurrentCity(employee.getCurrentCity());
        response.setBaseCity(employee.getBaseCity());
        
        return ResponseEntity.ok(response);
    }
}

