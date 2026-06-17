package com.corpconnect.backend.dto.help;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class HelpRequestCreateRequest {

    @NotNull
    private Long helperEmployeeId;

    @NotBlank
    private String message;
}
