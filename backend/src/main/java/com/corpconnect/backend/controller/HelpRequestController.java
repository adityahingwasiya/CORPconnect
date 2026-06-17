package com.corpconnect.backend.controller;

import com.corpconnect.backend.dto.help.HelpRequestCreateRequest;
import com.corpconnect.backend.dto.help.MyHelpRequestResponse;
import com.corpconnect.backend.entity.HelpRequest;
import com.corpconnect.backend.service.HelpRequestService;
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
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/help-requests")
public class HelpRequestController {

    private final HelpRequestService helpRequestService;

    public HelpRequestController(HelpRequestService helpRequestService) {
        this.helpRequestService = helpRequestService;
    }

    @PreAuthorize("hasRole('EMPLOYEE')")
    @PostMapping
    public ResponseEntity<Map<String, Object>> createHelpRequest(
            @Valid @RequestBody HelpRequestCreateRequest request
    ) {
        HelpRequest helpRequest = helpRequestService.createHelpRequest(request);

        Map<String, Object> responseBody = Map.of(
                "message", "Help request sent successfully",
                "requestId", helpRequest.getId(),
                "status", helpRequest.getStatus().name()
        );

        return ResponseEntity.status(HttpStatus.CREATED).body(responseBody);
    }

    @PreAuthorize("hasRole('EMPLOYEE')")
    @GetMapping("/my-requests")
    public ResponseEntity<List<MyHelpRequestResponse>> getMyRequests() {
        List<MyHelpRequestResponse> requests = helpRequestService.getMyRequests();
        return ResponseEntity.ok(requests);
    }

    @PreAuthorize("hasRole('EMPLOYEE')")
    @GetMapping("/assigned-to-me")
    public ResponseEntity<List<HelpRequest>> getRequestsAssignedToMe() {
        List<HelpRequest> requests = helpRequestService.getRequestsAssignedToMe();
        return ResponseEntity.ok(requests);
    }

    @PreAuthorize("hasRole('EMPLOYEE')")
    @PatchMapping("/{requestId}/accept")
    public ResponseEntity<Map<String, String>> acceptRequest(@PathVariable Long requestId) {
        HelpRequest helpRequest = helpRequestService.acceptRequest(requestId);
        return ResponseEntity.ok(Map.of(
                "message", "Request accepted",
                "status", helpRequest.getStatus().name()
        ));
    }

    @PreAuthorize("hasRole('EMPLOYEE')")
    @PatchMapping("/{requestId}/resolve")
    public ResponseEntity<Map<String, String>> resolveRequest(@PathVariable Long requestId) {
        HelpRequest helpRequest = helpRequestService.resolveRequest(requestId);
        return ResponseEntity.ok(Map.of(
                "message", "Request resolved",
                "status", helpRequest.getStatus().name()
        ));
    }
}
