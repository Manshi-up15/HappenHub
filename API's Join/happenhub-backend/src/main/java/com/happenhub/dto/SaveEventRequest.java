package com.happenhub.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDateTime;

// ─── Request ────────────────────────────────────────────────
@Data
public class SaveEventRequest {
    @NotNull(message = "User ID is required")
    private Long userId;

    @NotNull(message = "Event ID is required")
    private Long eventId;
}
