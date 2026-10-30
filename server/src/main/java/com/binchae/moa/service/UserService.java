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

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final BudgetRatioRepository budgetRatioRepository;
    private final TransactionRepository transactionRepository;
    private final BudgetCategoryRepository budgetCategoryRepository;
    private final PasswordEncoder passwordEncoder;

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
