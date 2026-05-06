package com.happenhub.controller;

import com.happenhub.dto.ApiResponse;
import com.happenhub.dto.SaveEventRequest;
import com.happenhub.dto.SavedEventResponse;
import com.happenhub.service.SavedEventService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * REST API for saving/bookmarking events.
 * All endpoints require authentication.
 *
 *   POST   /api/saved              - bookmark an event
 *   GET    /api/saved/{userId}     - get all bookmarks for a user
 *   DELETE /api/saved/{id}         - remove a bookmark
 */
@RestController
@RequestMapping("/api/saved")
@CrossOrigin(origins = "*")
@PreAuthorize("isAuthenticated()")
public class SavedEventController {

    @Autowired
    private SavedEventService savedEventService;

    /**
     * POST /api/saved
     * Body: { "userId": 1, "eventId": 5 }
     */
    @PostMapping
    public ResponseEntity<ApiResponse<SavedEventResponse>> saveEvent(
            @Valid @RequestBody SaveEventRequest request) {

        SavedEventResponse saved = savedEventService.saveEvent(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok("Event saved successfully", saved));
    }

    /**
     * GET /api/saved/{userId}
     * Returns all events bookmarked by a specific user.
     */
    @GetMapping("/{userId}")
    public ResponseEntity<ApiResponse<List<SavedEventResponse>>> getSavedEvents(
            @PathVariable Long userId) {

        List<SavedEventResponse> saved = savedEventService.getSavedEventsByUser(userId);
        return ResponseEntity.ok(ApiResponse.ok("Saved events retrieved", saved));
    }

    /**
     * DELETE /api/saved/{id}
     * Removes a bookmark by its own ID (not the event ID).
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> removeSavedEvent(@PathVariable Long id) {
        savedEventService.removeSavedEvent(id);
        return ResponseEntity.ok(ApiResponse.ok("Event removed from saved list"));
    }
}
