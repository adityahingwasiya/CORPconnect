package com.corpconnect.backend.service;

import com.corpconnect.backend.dto.employee.EmployeeCreateRequest;
import com.corpconnect.backend.dto.employee.EmployeeSummaryResponse;
import com.corpconnect.backend.dto.employee.UpdateLocationRequest;
import com.corpconnect.backend.entity.Company;
import com.corpconnect.backend.entity.Employee;
import com.corpconnect.backend.entity.EmployeeRole;
import com.corpconnect.backend.exception.BadRequestException;
import com.corpconnect.backend.exception.DuplicateResourceException;
import com.corpconnect.backend.exception.ResourceNotFoundException;
import com.corpconnect.backend.repository.CompanyRepository;
import com.corpconnect.backend.repository.EmployeeRepository;
import com.corpconnect.backend.util.SecurityUtil;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class EmployeeService {

    private final EmployeeRepository employeeRepository;
    private final CompanyRepository companyRepository;
    private final PasswordEncoder passwordEncoder;

    public EmployeeService(EmployeeRepository employeeRepository,
                           CompanyRepository companyRepository,
                           PasswordEncoder passwordEncoder) {
        this.employeeRepository = employeeRepository;
        this.companyRepository = companyRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public List<Employee> getEmployeesByCompany(Long companyId) {
        return employeeRepository.findByCompanyId(companyId);
    }

    public Employee createEmployee(EmployeeCreateRequest request) {
        Company company = companyRepository.findById(request.getCompanyId())
                .orElseThrow(() -> new ResourceNotFoundException("Company not found"));

        if (employeeRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new DuplicateResourceException("Email already exists");
        }

        String encodedPassword = passwordEncoder.encode(request.getPassword());

        Employee employee = new Employee();
        employee.setCompany(company);
        employee.setName(request.getName());
        employee.setEmail(request.getEmail());
        employee.setPasswordHash(encodedPassword);
        employee.setBaseCity(request.getBaseCity());
        employee.setCurrentCity(request.getBaseCity());
        employee.setPhone(request.getPhone());
        employee.setRole(EmployeeRole.valueOf(request.getRole()));

        return employeeRepository.save(employee);
    }

    public Employee updateCurrentLocation(UpdateLocationRequest request) {
        String email = SecurityUtil.getCurrentUserEmail();
        if (email == null) {
            throw new BadRequestException("No authenticated user found");
        }

        Employee employee = employeeRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("Employee not found"));

        employee.setCurrentCity(request.getCurrentCity());

        return employeeRepository.save(employee);
    }

    public List<EmployeeSummaryResponse> findColleaguesInCity(String city) {
        String email = SecurityUtil.getCurrentUserEmail();
        if (email == null) {
            throw new BadRequestException("No authenticated user found");
        }

        Employee loggedInEmployee = employeeRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("Employee not found"));

        String searchCity = (city == null || city.isBlank())
                ? loggedInEmployee.getCurrentCity()
                : city;

        searchCity = searchCity == null ? null : searchCity.trim();
        if (searchCity == null || searchCity.isBlank()) {
            return List.of();
        }

        List<Employee> colleagues = employeeRepository.findColleaguesByCompanyAndCity(
                loggedInEmployee.getCompany().getId(),
                searchCity,
                loggedInEmployee.getId()
        );

        return colleagues.stream()
                .map(employee -> {
                    EmployeeSummaryResponse response = new EmployeeSummaryResponse();
                    response.setId(employee.getId());
                    response.setName(employee.getName());
                    response.setEmail(employee.getEmail());
                    response.setPhone(employee.getPhone());
                    response.setBaseCity(employee.getBaseCity());
                    response.setCurrentCity(employee.getCurrentCity());
                    return response;
                })
                .collect(Collectors.toList());
    }
}
