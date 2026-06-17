package com.corpconnect.backend.dto.help;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * DTO for help requests created by the currently logged-in employee.
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class MyHelpRequestResponse {

    private Long requestId;
    private String message;
    private String status;
    private String helperName;
    private String helperEmail;
}
