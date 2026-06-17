package com.corpconnect.backend.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Collections;

/**
 * JWT Authentication Filter that processes JWT tokens from Authorization header.
 * Extracts and validates JWT tokens, then sets authentication in SecurityContext.
 * 
 * This filter does not block requests - it only sets authentication if a valid token is present.
 */
@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtUtil jwtUtil;

    public JwtAuthenticationFilter(JwtUtil jwtUtil) {
        this.jwtUtil = jwtUtil;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, 
                                    HttpServletResponse response, 
                                    FilterChain filterChain) throws ServletException, IOException {
        
        String authHeader = request.getHeader("Authorization");

        // Skip filtering if Authorization header is missing
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        // Extract token from "Bearer <token>" format
        String token = authHeader.substring(7);

        // Validate token and set authentication if valid
        if (jwtUtil.isTokenValid(token)) {
            try {
                String email = jwtUtil.extractEmail(token);
                String role = jwtUtil.extractRole(token);

                // Create authentication token with role as authority
                var authorities = Collections.singletonList(new SimpleGrantedAuthority("ROLE_" + role));
                var authentication = new UsernamePasswordAuthenticationToken(
                    email, 
                    null, 
                    authorities
                );

                // Set authentication in SecurityContext
                SecurityContextHolder.getContext().setAuthentication(authentication);
            } catch (Exception e) {
                // If extraction fails, continue without authentication
                // Do not block the request
            }
        }

        // Continue filter chain (do not block request)
        filterChain.doFilter(request, response);
    }
}
