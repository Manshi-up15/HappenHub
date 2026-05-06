package com.happenhub.repository;

import com.happenhub.model.SavedEvent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SavedEventRepository extends JpaRepository<SavedEvent, Long> {

    // Fetch all events bookmarked by a user
    List<SavedEvent> findByUserId(Long userId);

    // Check if a user already saved a specific event
    boolean existsByUserIdAndEventId(Long userId, Long eventId);

    // Remove a specific bookmark by user+event combo
    Optional<SavedEvent> findByUserIdAndEventId(Long userId, Long eventId);
}
