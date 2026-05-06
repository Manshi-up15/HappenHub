package com.happenhub.service;

import com.happenhub.dto.EventRequest;
import com.happenhub.dto.EventResponse;
import com.happenhub.exception.ResourceNotFoundException;
import com.happenhub.model.Event;
import com.happenhub.model.User;
import com.happenhub.repository.EventRepository;
import com.happenhub.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Business logic for event CRUD, search, and filtering.
 */
@Service
public class EventService {

    @Autowired
    private EventRepository eventRepository;

    @Autowired
    private UserRepository userRepository;

    // ── CREATE ────────────────────────────────────────────────────────────────

    @Transactional
    public EventResponse createEvent(EventRequest request, Long creatorId) {
        User creator = userRepository.findById(creatorId)
                .orElseThrow(() -> new ResourceNotFoundException("User", creatorId));

        Event event = mapToEntity(request, new Event());
        event.setCreatedBy(creator);

        return mapToResponse(eventRepository.save(event));
    }

    // ── READ ──────────────────────────────────────────────────────────────────

    public List<EventResponse> getAllEvents() {
        return eventRepository.findAll()
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    public EventResponse getEventById(Long id) {
        return eventRepository.findById(id)
                .map(this::mapToResponse)
                .orElseThrow(() -> new ResourceNotFoundException("Event", id));
    }

    /**
     * Filter events by category, mood, and/or date range.
     * Any parameter can be null (treated as "no filter").
     */
    public List<EventResponse> filterEvents(String category, String mood,
                                             LocalDate from, LocalDate to) {
        return eventRepository.findByFilters(category, mood, from, to)
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    /**
     * Full-text keyword search across title, description, location.
     */
    public List<EventResponse> searchEvents(String keyword) {
        return eventRepository.searchByKeyword(keyword)
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    /**
     * Return events happening today or later (for "New to City" / upcoming feed).
     */
    public List<EventResponse> getUpcomingEvents() {
        return eventRepository.findByDateGreaterThanEqual(LocalDate.now())
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    // ── UPDATE ────────────────────────────────────────────────────────────────

    @Transactional
    public EventResponse updateEvent(Long id, EventRequest request) {
        Event event = eventRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Event", id));

        mapToEntity(request, event); // update fields in place
        return mapToResponse(eventRepository.save(event));
    }

    // ── DELETE ────────────────────────────────────────────────────────────────

    @Transactional
    public void deleteEvent(Long id) {
        if (!eventRepository.existsById(id)) {
            throw new ResourceNotFoundException("Event", id);
        }
        eventRepository.deleteById(id);
    }

    // ── MAPPING HELPERS ───────────────────────────────────────────────────────

    private Event mapToEntity(EventRequest req, Event event) {
        event.setTitle(req.getTitle());
        event.setDescription(req.getDescription());
        event.setCategory(req.getCategory());
        event.setMood(req.getMood());
        event.setLocation(req.getLocation());
        event.setDate(req.getDate());
        event.setTime(req.getTime());
        return event;
    }

    private EventResponse mapToResponse(Event event) {
        EventResponse response = new EventResponse();
        response.setId(event.getId());
        response.setTitle(event.getTitle());
        response.setDescription(event.getDescription());
        response.setCategory(event.getCategory());
        response.setMood(event.getMood());
        response.setLocation(event.getLocation());
        response.setDate(event.getDate());
        response.setTime(event.getTime());
        response.setCreatedAt(event.getCreatedAt());
        response.setCreatedById(event.getCreatedBy().getId());
        response.setCreatedByName(event.getCreatedBy().getName());
        return response;
    }
}
