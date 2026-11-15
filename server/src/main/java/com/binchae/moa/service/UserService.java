package com.binchae.moa.service;

import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.binchae.moa.entity.User;
import com.binchae.moa.exception.ApiException;
import com.binchae.moa.repository.BudgetCategoryRepository;
import com.binchae.moa.repository.BudgetRatioRepository;
import com.binchae.moa.repository.TransactionRepository;
import com.binchae.moa.repository.UserRepository;
import com.binchae.moa.dto.UserResponse;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final BudgetRatioRepository budgetRatioRepository;
    private final TransactionRepository transactionRepository;
    private final BudgetCategoryRepository budgetCategoryRepository;
    private final PasswordEncoder passwordEncoder;

    // 내 정보 조회 (마이페이지 이메일 표시용)
    // 토큰은 유효하지만 탈퇴 등으로 사용자가 없으면 404
    @Transactional(readOnly = true)
    public UserResponse getMe(Long userId) {
        // userId로 사용자 찾기, 없으면 404 예외
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "사용자를 찾을 수 없습니다."));
        return UserResponse.from(user); // 엔티티 → DTO 변환 (password는 빠짐)
    }

    @Transactional
    public void withdraw(Long userId, String password) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "사용자를 찾을 수 없습니다."));

        if (!passwordEncoder.matches(password, user.getPassword())) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "비밀번호가 올바르지 않습니다.");
        }

        budgetRatioRepository.deleteByUser(user);
        transactionRepository.deleteByUser(user);
        budgetCategoryRepository.deleteByUser(user);
        userRepository.delete(user);
    }
}
