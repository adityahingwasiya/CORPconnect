package com.corpconnect.backend.controller;

import com.corpconnect.backend.dto.employee.EmployeeCreateRequest;
import com.corpconnect.backend.dto.employee.EmployeeSummaryResponse;
import com.corpconnect.backend.dto.employee.UpdateLocationRequest;
import com.corpconnect.backend.entity.Employee;
import com.corpconnect.backend.service.EmployeeService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/employees")
public class EmployeeController {

    private final EmployeeService employeeService;

    public EmployeeController(EmployeeService employeeService) {
        this.employeeService = employeeService;
    }

    @GetMapping("/company/{companyId}")
    public ResponseEntity<List<Employee>> getEmployeesByCompany(@PathVariable Long companyId) {
        List<Employee> employees = employeeService.getEmployeesByCompany(companyId);
        return ResponseEntity.ok(employees);
    }

    @PostMapping("/create")
    public ResponseEntity<Map<String, Object>> createEmployee(@Valid @RequestBody EmployeeCreateRequest request) {
        Employee employee = employeeService.createEmployee(request);

        Map<String, Object> responseBody = Map.of(
                "message", "Employee created successfully",
                "employeeId", employee.getId()
        );

        return ResponseEntity.status(HttpStatus.CREATED).body(responseBody);
    }

    @PreAuthorize("hasRole('EMPLOYEE')")
    @PatchMapping("/me/location")
    public ResponseEntity<Map<String, Object>> updateCurrentLocation(
            @Valid @RequestBody UpdateLocationRequest request
    ) {
        Employee employee = employeeService.updateCurrentLocation(request);

        Map<String, Object> responseBody = Map.of(
                "message", "Location updated successfully",
                "currentCity", employee.getCurrentCity()
        );

        return ResponseEntity.ok(responseBody);
    }

    @PreAuthorize("hasRole('EMPLOYEE')")
    @GetMapping("/me/colleagues")
    public ResponseEntity<List<EmployeeSummaryResponse>> findColleaguesInCity(
            @RequestParam(required = false) String city
    ) {
        List<EmployeeSummaryResponse> colleagues = employeeService.findColleaguesInCity(city);
        return ResponseEntity.ok(colleagues);
    }
}
