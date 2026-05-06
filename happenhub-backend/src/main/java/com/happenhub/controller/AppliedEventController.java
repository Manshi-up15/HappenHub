package com.happenhub.controller;

import com.happenhub.dto.ApiResponse;
import com.happenhub.dto.ApplyEventRequest;
import com.happenhub.dto.AppliedEventResponse;
import com.happenhub.service.AppliedEventService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/applied")
@CrossOrigin(origins = "*")
@PreAuthorize("isAuthenticated()")
public class AppliedEventController {

    @Autowired
    private AppliedEventService appliedEventService;

    @PostMapping
    public ResponseEntity<ApiResponse<AppliedEventResponse>> applyEvent(
            @Valid @RequestBody ApplyEventRequest request) {

        AppliedEventResponse applied = appliedEventService.applyEvent(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok("Event applied successfully", applied));
    }

    @GetMapping("/{userId}")
    public ResponseEntity<ApiResponse<List<AppliedEventResponse>>> getAppliedEvents(
            @PathVariable Long userId) {

        List<AppliedEventResponse> applied = appliedEventService.getAppliedEventsByUser(userId);
        return ResponseEntity.ok(ApiResponse.ok("Applied events retrieved", applied));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> removeAppliedEvent(@PathVariable Long id) {
        appliedEventService.removeAppliedEvent(id);
        return ResponseEntity.ok(ApiResponse.ok("Event removed from applied list"));
    }
}
