package com.happenhub.service;

import com.happenhub.dto.AuthResponse;
import com.happenhub.dto.LoginRequest;
import com.happenhub.dto.RegisterRequest;
import com.happenhub.exception.DuplicateResourceException;
import com.happenhub.model.User;
import com.happenhub.repository.UserRepository;
import com.happenhub.security.JwtUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Handles user registration and login, returning JWT tokens.
 */
@Service
public class AuthService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private JwtUtils jwtUtils;

    /**
     * Register a new user.
     * @throws DuplicateResourceException if email is already taken.
     */
    @Transactional
    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new DuplicateResourceException("Email is already registered: " + request.getEmail());
        }

        User user = new User();
        user.setName(request.getName());
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setRole(request.getRole() != null ? request.getRole() : User.Role.USER);

        userRepository.save(user);

        // Generate token so user is logged in immediately after registering
        String token = jwtUtils.generateTokenFromEmail(user.getEmail());
        return new AuthResponse(token, user.getId(), user.getName(), user.getEmail(), user.getRole());
    }

    /**
     * Authenticate existing user and return JWT.
     */
    public AuthResponse login(LoginRequest request) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
        );

        SecurityContextHolder.getContext().setAuthentication(authentication);
        String token = jwtUtils.generateToken(authentication);

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow();

        return new AuthResponse(token, user.getId(), user.getName(), user.getEmail(), user.getRole());
    }
}
