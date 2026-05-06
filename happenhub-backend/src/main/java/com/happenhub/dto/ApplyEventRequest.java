package com.happenhub.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class ApplyEventRequest {
    @NotNull(message = "User ID is required")
    private Long userId;

    @NotNull(message = "Event ID is required")
    private Long eventId;
}
