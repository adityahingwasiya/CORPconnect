package com.corpconnect.backend.controller;

import com.corpconnect.backend.entity.Company;
import com.corpconnect.backend.repository.CompanyRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/companies")
public class CompanyController {

    @Autowired
    private CompanyRepository companyRepository;

    @PostMapping("/test-create")
    public Company createTestCompany() {
        Company company = new Company();
        company.setName("Test Corp");
        company.setEmail("test@example.com");
        company.setPasswordHash("dummy");
        
        return companyRepository.save(company);
    }

    @GetMapping
    public List<Company> getAllCompanies() {
        return companyRepository.findAll();
    }
}


