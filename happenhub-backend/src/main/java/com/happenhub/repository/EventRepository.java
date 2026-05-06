package com.happenhub.repository;

import com.happenhub.model.Event;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface EventRepository extends JpaRepository<Event, Long> {

    // All events by a specific creator
    List<Event> findByCreatedById(Long userId);

    // Filter by category (case-insensitive)
    List<Event> findByCategoryIgnoreCase(String category);

    // Filter by mood tag
    List<Event> findByMoodIgnoreCase(String mood);

    // Events on or after a given date (upcoming)
    List<Event> findByDateGreaterThanEqual(LocalDate date);

    // Full-text search across title, description, location
    @Query("SELECT e FROM Event e WHERE " +
           "LOWER(e.title) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(e.description) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(e.location) LIKE LOWER(CONCAT('%', :keyword, '%'))")
    List<Event> searchByKeyword(@Param("keyword") String keyword);

    // Combined filter: category + mood + date range
    @Query("SELECT e FROM Event e WHERE " +
           "(:category IS NULL OR LOWER(e.category) = LOWER(:category)) AND " +
           "(:mood IS NULL OR LOWER(e.mood) = LOWER(:mood)) AND " +
           "(:from IS NULL OR e.date >= :from) AND " +
           "(:to IS NULL OR e.date <= :to)")
    List<Event> findByFilters(
            @Param("category") String category,
            @Param("mood") String mood,
            @Param("from") LocalDate from,
            @Param("to") LocalDate to
    );
}
