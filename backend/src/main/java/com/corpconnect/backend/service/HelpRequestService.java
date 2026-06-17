package com.corpconnect.backend.service;

import com.corpconnect.backend.dto.help.HelpRequestCreateRequest;
import com.corpconnect.backend.dto.help.MyHelpRequestResponse;
import com.corpconnect.backend.entity.Employee;
import com.corpconnect.backend.entity.HelpRequest;
import com.corpconnect.backend.entity.HelpRequestStatus;
import com.corpconnect.backend.exception.BadRequestException;
import com.corpconnect.backend.repository.EmployeeRepository;
import com.corpconnect.backend.repository.HelpRequestRepository;
import com.corpconnect.backend.util.SecurityUtil;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class HelpRequestService {

    private final HelpRequestRepository helpRequestRepository;
    private final EmployeeRepository employeeRepository;

    public HelpRequestService(HelpRequestRepository helpRequestRepository,
                              EmployeeRepository employeeRepository) {
        this.helpRequestRepository = helpRequestRepository;
        this.employeeRepository = employeeRepository;
    }

    private Employee getCurrentUserAsHelper() {
        String email = SecurityUtil.getCurrentUserEmail();
        if (email == null) {
            throw new BadRequestException("No authenticated user found");
        }
        return employeeRepository.findByEmail(email)
                .orElseThrow(() -> new BadRequestException("Employee not found with email: " + email));
    }

    public HelpRequest createHelpRequest(HelpRequestCreateRequest request) {
        String email = SecurityUtil.getCurrentUserEmail();
        if (email == null) {
            throw new BadRequestException("No authenticated user found");
        }

        Employee requester = employeeRepository.findByEmail(email)
                .orElseThrow(() -> new BadRequestException("Employee not found with email: " + email));

        Employee helper = employeeRepository.findById(request.getHelperEmployeeId())
                .orElseThrow(() -> new BadRequestException("Helper employee not found with id: " + request.getHelperEmployeeId()));

        if (requester.getId().equals(helper.getId())) {
            throw new BadRequestException("Requester and helper cannot be the same employee. Use a different colleague's ID as helperEmployeeId.");
        }

        if (requester.getCompany() == null || helper.getCompany() == null
                || !requester.getCompany().getId().equals(helper.getCompany().getId())) {
            throw new BadRequestException("Requester and helper must belong to the same company");
        }

        HelpRequest helpRequest = new HelpRequest();
        helpRequest.setRequester(requester);
        helpRequest.setHelper(helper);
        helpRequest.setMessage(request.getMessage());
        helpRequest.setStatus(HelpRequestStatus.PENDING);

        return helpRequestRepository.save(helpRequest);
    }

    public List<HelpRequest> getRequestsAssignedToMe() {
        Employee helper = getCurrentUserAsHelper();
        return helpRequestRepository.findByHelperId(helper.getId());
    }

    public List<MyHelpRequestResponse> getMyRequests() {
        Employee requester = getCurrentUserAsHelper();
        List<HelpRequest> requests = helpRequestRepository
                .findByRequesterIdOrderByCreatedAtDesc(requester.getId());
        return requests.stream().map(hr -> {
            MyHelpRequestResponse dto = new MyHelpRequestResponse();
            dto.setRequestId(hr.getId());
            dto.setMessage(hr.getMessage());
            dto.setStatus(hr.getStatus().name());
            if (hr.getHelper() != null) {
                dto.setHelperName(hr.getHelper().getName());
                dto.setHelperEmail(hr.getHelper().getEmail());
            }
            return dto;
        }).collect(Collectors.toList());
    }

    public HelpRequest acceptRequest(Long requestId) {
        Employee helper = getCurrentUserAsHelper();
        HelpRequest helpRequest = helpRequestRepository.findByIdAndHelperId(requestId, helper.getId())
                .orElseThrow(() -> new BadRequestException("Help request not found or not assigned to you"));
        if (helpRequest.getStatus() != HelpRequestStatus.PENDING) {
            throw new BadRequestException("Only PENDING requests can be accepted");
        }
        helpRequest.setStatus(HelpRequestStatus.ACCEPTED);
        return helpRequestRepository.save(helpRequest);
    }

    public HelpRequest resolveRequest(Long requestId) {
        Employee helper = getCurrentUserAsHelper();
        HelpRequest helpRequest = helpRequestRepository.findByIdAndHelperId(requestId, helper.getId())
                .orElseThrow(() -> new BadRequestException("Help request not found or not assigned to you"));
        if (helpRequest.getStatus() != HelpRequestStatus.ACCEPTED) {
            throw new BadRequestException("Only ACCEPTED requests can be resolved");
        }
        helpRequest.setStatus(HelpRequestStatus.RESOLVED);
        return helpRequestRepository.save(helpRequest);
    }
}
