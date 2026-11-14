package com.binchae.moa.controller;

import com.binchae.moa.config.JwtProvider;
import com.binchae.moa.dto.SignUpRequest;
import com.binchae.moa.dto.LoginRequest;
import com.binchae.moa.dto.TokenResponse;
import com.binchae.moa.entity.User;
import com.binchae.moa.service.AuthService;
import com.binchae.moa.dto.EmailCheckResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

import org.springframework.web.bind.annotation.*;

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

    // 이메일 중복 확인: GET /api/auth/check-email?email=a@a.com
    // /api/auth/** 는 SecurityConfig에서 열어 둬서 토큰 없이 호출 가능 (가입 전이라 토큰이 없음)
    @GetMapping("/check-email")
    public EmailCheckResponse checkEmail(@RequestParam String email) {
        boolean available = authService.isEmailAvailable(email); // Service: 비즈니스 결과(boolean)
        return new EmailCheckResponse(available);                // Controller: 응답 모양(DTO)으로 감싸기
    }

}