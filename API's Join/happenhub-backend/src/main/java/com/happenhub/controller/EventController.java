package com.happenhub.controller;

import com.happenhub.dto.ApiResponse;
import com.happenhub.dto.EventRequest;
import com.happenhub.dto.EventResponse;
import com.happenhub.service.EventService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

/**
 * REST API for event discovery and management.
 *
 * Public (no token needed):
 *   GET /api/events          - list all events (with optional filters)
 *   GET /api/events/{id}     - event detail
 *   GET /api/events/search   - keyword search
 *   GET /api/events/upcoming - future events only
 *
 * Protected (JWT required):
 *   POST   /api/events        - create event (BUSINESS role)
 *   PUT    /api/events/{id}   - update event
 *   DELETE /api/events/{id}   - delete event
 */
@RestController
@RequestMapping("/api/events")
@CrossOrigin(origins = "*")
public class EventController {

    @Autowired
    private EventService eventService;

    // ── PUBLIC ENDPOINTS ──────────────────────────────────────────────────────

    /**
     * GET /api/events
     * Optional query params: category, mood, from (yyyy-MM-dd), to (yyyy-MM-dd)
     * Returns filtered list or all events if no params provided.
     */
    @GetMapping
    public ResponseEntity<ApiResponse<List<EventResponse>>> getAllEvents(
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String mood,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to) {

        List<EventResponse> events;

        // If any filter is supplied, use the filter query; otherwise return all
        if (category != null || mood != null || from != null || to != null) {
            events = eventService.filterEvents(category, mood, from, to);
        } else {
            events = eventService.getAllEvents();
        }

        return ResponseEntity.ok(ApiResponse.ok("Events retrieved", events));
    }

    /**
     * GET /api/events/search?keyword=music
     */
    @GetMapping("/search")
    public ResponseEntity<ApiResponse<List<EventResponse>>> searchEvents(
            @RequestParam String keyword) {

        List<EventResponse> results = eventService.searchEvents(keyword);
        return ResponseEntity.ok(ApiResponse.ok("Search results", results));
    }

    /**
     * GET /api/events/upcoming
     * Events from today onwards — useful for "New to City" suggestions.
     */
    @GetMapping("/upcoming")
    public ResponseEntity<ApiResponse<List<EventResponse>>> getUpcomingEvents() {
        return ResponseEntity.ok(ApiResponse.ok("Upcoming events", eventService.getUpcomingEvents()));
    }

    /**
     * GET /api/events/{id}
     */
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<EventResponse>> getEventById(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.ok("Event found", eventService.getEventById(id)));
    }

    // ── PROTECTED ENDPOINTS ───────────────────────────────────────────────────

    /**
     * POST /api/events
     * Body must include createdById (the logged-in user's ID).
     * Restricted to BUSINESS role users.
     */
    @PostMapping
    @PreAuthorize("hasRole('BUSINESS')")
    public ResponseEntity<ApiResponse<EventResponse>> createEvent(
            @Valid @RequestBody EventRequest request,
            @RequestParam Long createdById) {

        EventResponse created = eventService.createEvent(request, createdById);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok("Event created successfully", created));
    }

    /**
     * PUT /api/events/{id}
     */
    @PutMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<ApiResponse<EventResponse>> updateEvent(
            @PathVariable Long id,
            @Valid @RequestBody EventRequest request) {

        EventResponse updated = eventService.updateEvent(id, request);
        return ResponseEntity.ok(ApiResponse.ok("Event updated successfully", updated));
    }

    /**
     * DELETE /api/events/{id}
     */
    @DeleteMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<ApiResponse<Void>> deleteEvent(@PathVariable Long id) {
        eventService.deleteEvent(id);
        return ResponseEntity.ok(ApiResponse.ok("Event deleted successfully"));
    }
}
