package com.happenhub.repository;

import com.happenhub.model.AppliedEvent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AppliedEventRepository extends JpaRepository<AppliedEvent, Long> {
    List<AppliedEvent> findByUserId(Long userId);
    boolean existsByUserIdAndEventId(Long userId, Long eventId);
}
