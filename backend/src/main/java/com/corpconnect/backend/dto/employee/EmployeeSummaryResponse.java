package com.corpconnect.backend.dto.employee;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class EmployeeSummaryResponse {

    private Long id;
    private String name;
    private String email;
    private String phone;
    private String baseCity;
    private String currentCity;
}

