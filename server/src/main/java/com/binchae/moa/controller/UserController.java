package com.binchae.moa.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.GetMapping;

import com.binchae.moa.dto.UserResponse;
import com.binchae.moa.dto.WithdrawRequest;
import com.binchae.moa.service.UserService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    // 내 정보 조회: GET /api/users/me
    // 누구인지는 토큰으로 판단 (JwtAuthFilter가 넣어 준 userId)
    @GetMapping("/me")
    public UserResponse getMe(@AuthenticationPrincipal Long userId) {
        return userService.getMe(userId);
    }

    @DeleteMapping("/me")
    public ResponseEntity<Void> withdraw(
            @AuthenticationPrincipal Long userId,
            @Valid @RequestBody WithdrawRequest request) {
        userService.withdraw(userId, request.getPassword());
        return ResponseEntity.noContent().build();
    }
}