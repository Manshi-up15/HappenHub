package com.happenhub.dto;

import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

/**
 * Clean event response — avoids exposing lazy-loaded JPA proxies.
 */
@Data
public class EventResponse {
    private Long id;
    private String title;
    private String description;
    private String category;
    private String mood;
    private String location;
    private LocalDate date;
    private LocalTime time;
    private LocalDateTime createdAt;
    private Long createdById;
    private String createdByName;
    private String imageUrl;
    private Double price;
}
