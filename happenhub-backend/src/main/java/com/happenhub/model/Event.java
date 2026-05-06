package com.happenhub.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

/**
 * Represents an event created by a BUSINESS user.
 * Contains all details needed for discovery and display.
 */
@Entity
@Table(name = "events")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Event {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank
    @Size(max = 200)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    @NotBlank
    @Size(max = 100)
    private String category;

    // Mood tags e.g. "fun", "chill", "productive"
    @Size(max = 50)
    private String mood;

    @NotBlank
    @Size(max = 255)
    private String location;

    @NotNull
    private LocalDate date;

    private LocalTime time;

    @Column(name = "image_url")
    private String imageUrl;

    private Double price;

    // Timestamp when the event record was created
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by", nullable = false)
    private User createdBy;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
    }
}
