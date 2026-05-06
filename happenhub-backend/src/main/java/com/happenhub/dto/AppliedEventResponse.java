package com.happenhub.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class AppliedEventResponse {
    private Long id;
    private Long userId;
    private EventResponse event;
    private LocalDateTime appliedAt;
}
