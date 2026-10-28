package com.binchae.moa.controller;

import com.binchae.moa.config.JwtProvider;
import com.binchae.moa.dto.SignUpRequest;
import com.binchae.moa.dto.LoginRequest;
import com.binchae.moa.dto.TokenResponse;
import com.binchae.moa.entity.User;
import com.binchae.moa.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;


@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
    private final JwtProvider jwtProvider;

    @PostMapping("/signup")
    public TokenResponse signUp(@Valid @RequestBody SignUpRequest request) {
        User user = authService.signUp(request.getEmail(), request.getPassword());
        String token = jwtProvider.createToken(user.getId());
        return new TokenResponse(token);
    }

    @PostMapping("/login")
    public TokenResponse login(@Valid @RequestBody LoginRequest request) {
        User user = authService.signIn(request.getEmail(), request.getPassword());
        String token = jwtProvider.createToken(user.getId());
        return new TokenResponse(token);
    }

    @GetMapping("/me")
    public Long me(@AuthenticationPrincipal Long userId) {
        return userId;
    }
    
}