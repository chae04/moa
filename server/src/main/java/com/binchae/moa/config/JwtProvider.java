package com.binchae.moa.config;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;

@Component
public class JwtProvider {

    private final SecretKey key;
    private final long expirationMs;

    public JwtProvider(
            @Value("${jwt.secret}") String secret,  // properties에 적은 값을 주입받음
            @Value("${jwt.expiration-ms}") long expirationMs) {
        // 문자열 비밀키를 서명용 키 객체로 바꿈
        this.key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
        this.expirationMs = expirationMs;
    }

    // 토큰 발급: userId를 subject에 담는다
    public String createToken(Long userId) {
        Date now = new Date();
        return Jwts.builder()
                // subject : 토큰의 주인(userId)을 넣는 표준 필드
                .subject(String.valueOf(userId))
                .issuedAt(now)
                .expiration(new Date(now.getTime() + expirationMs))
                .signWith(key)  // 비밀키로 서명해서 위조를 막음.
                .compact();
    }

    // 토큰 검증 후 userId 반환 (위조/만료면 예외)
    public Long getUserId(String token) {
        Claims claims = Jwts.parser()
                .verifyWith(key)
                .build()
                // 서명을 검증하면서 내용을 꺼냄. 서명이 틀리거나 만료되면 예외가 터져서 isValid가 false 반환
                .parseSignedClaims(token)
                .getPayload();
        return Long.valueOf(claims.getSubject());
    }

    // 유효한 토큰인지만 확인
    public boolean isValid(String token) {
        try {
            getUserId(token);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            return false;
        }
    }
}