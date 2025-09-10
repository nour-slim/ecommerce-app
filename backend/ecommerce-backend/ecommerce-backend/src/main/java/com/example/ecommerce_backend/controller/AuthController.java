package com.example.ecommerce_backend.controller;

import com.example.ecommerce_backend.entity.User;
import com.example.ecommerce_backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/auth")
@CrossOrigin(origins = "http://localhost:54952") 
public class AuthController {

    @Autowired
    private UserRepository userRepository;

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody User user) {
        if(userRepository.findByEmail(user.getEmail()).isPresent()) {
            return ResponseEntity.badRequest().body("Email already in use");
        }
        if (user.getRole() == null) {
            user.setRole("CUSTOMER");
        }
        User savedUser = userRepository.save(user);
        return ResponseEntity.status(201).body(savedUser);
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody User user) {
        Optional<User> existingUser = userRepository.findByEmail(user.getEmail());
        if(existingUser.isPresent() && existingUser.get().getPassword().equals(user.getPassword())) {
            String role = existingUser.get().getRole();
            return ResponseEntity.ok().body("{\"token\":\"mock_jwt_token_123\", \"role\":\"" + role + "\"}");
        }
        return ResponseEntity.status(401).body("Invalid credentials");
    }

}
