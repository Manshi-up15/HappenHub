package com.happenhub.dto;

import com.happenhub.model.User;
import lombok.AllArgsConstructor;
import lombok.Data;

/**
 * Returned after a successful login or register.
 * Contains the JWT token and basic user info.
 */
@Data
@AllArgsConstructor
public class AuthResponse {
    private String token;
    private String type = "Bearer";
    private Long userId;
    private String name;
    private String email;
    private User.Role role;

    public AuthResponse(String token, Long userId, String name, String email, User.Role role) {
        this.token = token;
        this.userId = userId;
        this.name = name;
        this.email = email;
        this.role = role;
    }
}
