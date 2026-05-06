package com.happenhub.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "applied_events", uniqueConstraints = @UniqueConstraint(columnNames = { "user_id", "event_id" }))
@Data
@NoArgsConstructor
@AllArgsConstructor
public class AppliedEvent {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "event_id", nullable = false)
    private Event event;

    @Column(name = "applied_at", updatable = false)
    private LocalDateTime appliedAt;

    @PrePersist
    protected void onApply() {
        this.appliedAt = LocalDateTime.now();
    }
}
