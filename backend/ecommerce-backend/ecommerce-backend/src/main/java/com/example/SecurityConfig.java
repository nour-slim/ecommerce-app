package com.example.ecommerce_backend.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())      // disable CSRF for dev (modern syntax)
            .authorizeHttpRequests(authz -> authz
                .anyRequest().permitAll()      // allow all endpoints
            )
            .headers(headers -> headers
                .frameOptions(frameOptions -> frameOptions.disable()) // THIS FIXES THE H2 CONSOLE ISSUE
            );
        
        return http.build();
    }
}