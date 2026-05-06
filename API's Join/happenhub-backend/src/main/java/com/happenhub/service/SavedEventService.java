package com.happenhub.service;

import com.happenhub.dto.EventResponse;
import com.happenhub.dto.SaveEventRequest;
import com.happenhub.dto.SavedEventResponse;
import com.happenhub.exception.DuplicateResourceException;
import com.happenhub.exception.ResourceNotFoundException;
import com.happenhub.model.Event;
import com.happenhub.model.SavedEvent;
import com.happenhub.model.User;
import com.happenhub.repository.EventRepository;
import com.happenhub.repository.SavedEventRepository;
import com.happenhub.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Handles saving (bookmarking) and un-saving events for users.
 */
@Service
public class SavedEventService {

    @Autowired
    private SavedEventRepository savedEventRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private EventRepository eventRepository;

    /**
     * Bookmark an event for a user.
     */
    @Transactional
    public SavedEventResponse saveEvent(SaveEventRequest request) {
        // Validate both exist
        User user = userRepository.findById(request.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("User", request.getUserId()));
        Event event = eventRepository.findById(request.getEventId())
                .orElseThrow(() -> new ResourceNotFoundException("Event", request.getEventId()));

        // Prevent duplicate saves
        if (savedEventRepository.existsByUserIdAndEventId(user.getId(), event.getId())) {
            throw new DuplicateResourceException("Event already saved by this user");
        }

        SavedEvent saved = new SavedEvent();
        saved.setUser(user);
        saved.setEvent(event);

        return mapToResponse(savedEventRepository.save(saved));
    }

    /**
     * Get all bookmarked events for a specific user.
     */
    public List<SavedEventResponse> getSavedEventsByUser(Long userId) {
        if (!userRepository.existsById(userId)) {
            throw new ResourceNotFoundException("User", userId);
        }

        return savedEventRepository.findByUserId(userId)
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    /**
     * Remove a bookmark by its ID.
     */
    @Transactional
    public void removeSavedEvent(Long savedEventId) {
        if (!savedEventRepository.existsById(savedEventId)) {
            throw new ResourceNotFoundException("Saved event", savedEventId);
        }
        savedEventRepository.deleteById(savedEventId);
    }

    // ── MAPPING HELPERS ───────────────────────────────────────────────────────

    private SavedEventResponse mapToResponse(SavedEvent saved) {
        SavedEventResponse response = new SavedEventResponse();
        response.setId(saved.getId());
        response.setUserId(saved.getUser().getId());
        response.setSavedAt(saved.getSavedAt());

        // Inline the event details
        Event event = saved.getEvent();
        EventResponse eventResponse = new EventResponse();
        eventResponse.setId(event.getId());
        eventResponse.setTitle(event.getTitle());
        eventResponse.setDescription(event.getDescription());
        eventResponse.setCategory(event.getCategory());
        eventResponse.setMood(event.getMood());
        eventResponse.setLocation(event.getLocation());
        eventResponse.setDate(event.getDate());
        eventResponse.setTime(event.getTime());
        eventResponse.setCreatedAt(event.getCreatedAt());
        eventResponse.setCreatedById(event.getCreatedBy().getId());
        eventResponse.setCreatedByName(event.getCreatedBy().getName());

        response.setEvent(eventResponse);
        return response;
    }
}
