package com.happenhub.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalTime;

/**
 * Payload for creating or updating an event.
 */
@Data
public class EventRequest {

    @NotBlank(message = "Title is required")
    @Size(max = 200)
    private String title;

    private String description;

    @NotBlank(message = "Category is required")
    @Size(max = 100)
    private String category;

    @Size(max = 50)
    private String mood; // e.g. fun, chill, productive

    @NotBlank(message = "Location is required")
    @Size(max = 255)
    private String location;

    @NotNull(message = "Date is required")
    private LocalDate date;

    private LocalTime time;

    private String imageUrl;

    private Double price;
}
