package com.happenhub.service;

import com.happenhub.dto.ApplyEventRequest;
import com.happenhub.dto.AppliedEventResponse;
import com.happenhub.dto.EventResponse;
import com.happenhub.exception.DuplicateResourceException;
import com.happenhub.exception.ResourceNotFoundException;
import com.happenhub.model.Event;
import com.happenhub.model.AppliedEvent;
import com.happenhub.model.User;
import com.happenhub.repository.EventRepository;
import com.happenhub.repository.AppliedEventRepository;
import com.happenhub.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class AppliedEventService {

    @Autowired
    private AppliedEventRepository appliedEventRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private EventRepository eventRepository;

    @Transactional
    public AppliedEventResponse applyEvent(ApplyEventRequest request) {

        User user = userRepository.findById(request.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("User", request.getUserId()));

        Event event = eventRepository.findById(request.getEventId())
                .orElseThrow(() -> new ResourceNotFoundException("Event", request.getEventId()));

        AppliedEvent appliedEvent = new AppliedEvent();
        appliedEvent.setUser(user);
        appliedEvent.setEvent(event);

        return mapToResponse(appliedEventRepository.save(appliedEvent));
    }

    public List<AppliedEventResponse> getAppliedEventsByUser(Long userId) {
        return appliedEventRepository.findByUserId(userId)
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public void removeAppliedEvent(Long appliedId) {
        if (!appliedEventRepository.existsById(appliedId)) {
            throw new ResourceNotFoundException("AppliedEvent", appliedId);
        }
        appliedEventRepository.deleteById(appliedId);
    }

    private AppliedEventResponse mapToResponse(AppliedEvent appliedEvent) {
        AppliedEventResponse response = new AppliedEventResponse();
        response.setId(appliedEvent.getId());
        response.setUserId(appliedEvent.getUser().getId());
        response.setAppliedAt(appliedEvent.getAppliedAt());

        EventResponse eventResponse = new EventResponse();
        eventResponse.setId(appliedEvent.getEvent().getId());
        eventResponse.setTitle(appliedEvent.getEvent().getTitle());
        eventResponse.setDescription(appliedEvent.getEvent().getDescription());
        eventResponse.setCategory(appliedEvent.getEvent().getCategory());
        eventResponse.setMood(appliedEvent.getEvent().getMood());
        eventResponse.setLocation(appliedEvent.getEvent().getLocation());
        eventResponse.setDate(appliedEvent.getEvent().getDate());
        eventResponse.setTime(appliedEvent.getEvent().getTime());
        eventResponse.setImageUrl(appliedEvent.getEvent().getImageUrl());
        eventResponse.setCreatedAt(appliedEvent.getEvent().getCreatedAt());
        eventResponse.setCreatedById(appliedEvent.getEvent().getCreatedBy().getId());
        eventResponse.setCreatedByName(appliedEvent.getEvent().getCreatedBy().getName());
        eventResponse.setPrice(appliedEvent.getEvent().getPrice());
        response.setEvent(eventResponse);

        return response;
    }
}
