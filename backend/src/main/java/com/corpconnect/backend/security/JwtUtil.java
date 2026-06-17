package com.corpconnect.backend.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;

/**
 * Utility class for JWT token operations.
 * Handles token generation, extraction, and validation using HS256 algorithm.
 */
@Component
public class JwtUtil {

    @Value("${jwt.secret}")
    private String secret;

    @Value("${jwt.expiration}")
    private Long expiration;

    /**
     * Generates a JWT token with email, role, and userId claims.
     *
     * @param email  The user's email address
     * @param role   The user's role
     * @param userId The user's ID
     * @return Generated JWT token as a string
     */
    public String generateToken(String email, String role, Long userId) {
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + expiration);

        return Jwts.builder()
                .subject(email)
                .claim("role", role)
                .claim("userId", userId)
                .issuedAt(now)
                .expiration(expiryDate)
                .signWith(getSigningKey())
                .compact();
    }

    /**
     * Extracts the email (subject) from a JWT token.
     *
     * @param token The JWT token
     * @return The email address extracted from the token
     */
    public String extractEmail(String token) {
        return extractClaims(token).getSubject();
    }

    /**
     * Extracts the role from a JWT token.
     *
     * @param token The JWT token
     * @return The role extracted from the token
     */
    public String extractRole(String token) {
        return extractClaims(token).get("role", String.class);
    }

    /**
     * Extracts the userId from a JWT token.
     *
     * @param token The JWT token
     * @return The userId extracted from the token
     */
    public Long extractUserId(String token) {
        return extractClaims(token).get("userId", Long.class);
    }

    /**
     * Validates if a JWT token is valid (not expired and properly signed).
     *
     * @param token The JWT token to validate
     * @return true if the token is valid, false otherwise
     */
    public boolean isTokenValid(String token) {
        try {
            Claims claims = extractClaims(token);
            return !claims.getExpiration().before(new Date());
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Extracts all claims from a JWT token.
     *
     * @param token The JWT token
     * @return Claims object containing all token claims
     */
    private Claims extractClaims(String token) {
        return Jwts.parser()
                .verifyWith(getSigningKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    /**
     * Gets the signing key for JWT operations.
     *
     * @return SecretKey for HS256 algorithm
     */
    private SecretKey getSigningKey() {
        byte[] keyBytes = secret.getBytes(StandardCharsets.UTF_8);
        return Keys.hmacShaKeyFor(keyBytes);
    }
}
