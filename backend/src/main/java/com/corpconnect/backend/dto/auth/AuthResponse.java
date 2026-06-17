package com.corpconnect.backend.dto.auth;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class AuthResponse {

    private String token;
    private String role;
    private Long userId;

    // Employee-specific fields
    private String name;
    private String email;
    private String currentCity;
    private String baseCity;

    // Company-specific fields
    private String companyName;
}

