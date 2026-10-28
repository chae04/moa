package com.binchae.moa.service;

import com.binchae.moa.entity.User;
import com.binchae.moa.exception.ApiException;
import com.binchae.moa.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.http.HttpStatus;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    // 회원가입
    public User signUp(String email, String password) {
        if (userRepository.existsByEmail(email)) {
            throw new ApiException(HttpStatus.CONFLICT, "이미 사용 중인 이메일입니다.");
        }

        User user = new User();
        user.setEmail(email);
        user.setPassword(passwordEncoder.encode(password));

        return userRepository.save(user);
    }

    // 로그인
    public User signIn(String email, String password) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ApiException(HttpStatus.UNAUTHORIZED, "이메일 또는 비밀번호가 올바르지 않습니다."));

        if (!passwordEncoder.matches(password, user.getPassword())) {
            throw new ApiException(HttpStatus.UNAUTHORIZED, "이메일 또는 비밀번호가 올바르지 않습니다.");
        }

        return user;
    }
}