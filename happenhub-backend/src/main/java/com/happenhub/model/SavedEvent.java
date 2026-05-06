package com.happenhub.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Junction table for users bookmarking/saving events.
 * A unique constraint ensures a user can't save the same event twice.
 */
@Entity
@Table(name = "saved_events",
       uniqueConstraints = @UniqueConstraint(columnNames = {"user_id", "event_id"}))
@Data
@NoArgsConstructor
@AllArgsConstructor
public class SavedEvent {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "event_id", nullable = false)
    private Event event;

    @Column(name = "saved_at", updatable = false)
    private LocalDateTime savedAt;

    @PrePersist
    protected void onSave() {
        this.savedAt = LocalDateTime.now();
    }
}
