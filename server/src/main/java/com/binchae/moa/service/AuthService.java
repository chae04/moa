package com.binchae.moa.service;

import com.binchae.moa.entity.User;
import com.binchae.moa.exception.ApiException;
import com.binchae.moa.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.http.HttpStatus;

import com.binchae.moa.dto.BudgetRatioRequest;
import com.binchae.moa.dto.CategoryRequest;
import com.binchae.moa.dto.CategoryResponse;
import com.binchae.moa.dto.SignUpRequest;
import org.springframework.transaction.annotation.Transactional; // jakarta 것 아님!

import java.time.YearMonth;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final BudgetCategoryService budgetCategoryService; // 카테고리 생성 재사용
    private final BudgetRatioService budgetRatioService; // 비율 저장 재사용

    private static final int MAX_SHOW_ON_HOME = 5; // 앞에서 5개까지만 홈에 표시

    // 이메일 사용 가능 여부 (회원가입 첫 화면에서 중복 확인용)
    // true = 가입 가능, false = 이미 가입된 이메일
    public boolean isEmailAvailable(String email) {
        return !userRepository.existsByEmail(email);
    }

    // 회원가입 + 기본 카테고리 + 첫 비율 저장
    // 하나의 트랜잭션: 중간에 예외가 나면 회원까지 전부 롤백 → 같은 이메일로 다시 가입 가능
    @Transactional
    public User signUp(SignUpRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new ApiException(HttpStatus.CONFLICT, "이미 사용 중인 이메일입니다.");
        }

        User user = new User();
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        userRepository.save(user); // IDENTITY 전략이라 save 즉시 INSERT → user.getId() 사용 가능

        // 1) 카테고리 생성 + 만들어진 id로 비율 항목 만들기
        // 가입 시점엔 카테고리 id가 없어서, 만든 뒤 받은 id를 비율 요청에 넣는다
        List<BudgetRatioRequest.CategoryRatio> ratios = new ArrayList<>();
        List<SignUpRequest.CategoryItem> items = request.getCategories();
        for (int i = 0; i < items.size(); i++) { // 순서(i)가 필요해서 향상된 for문 대신 인덱스 사용
            SignUpRequest.CategoryItem item = items.get(i);

            CategoryRequest categoryRequest = new CategoryRequest(); // 기존 카테고리 추가 API의 요청 DTO 재사용
            categoryRequest.setName(item.getName());
            categoryRequest.setShowOnHome(i < MAX_SHOW_ON_HOME);
            categoryRequest.setIncludeInDaily(item.getIncludeInDaily());
            CategoryResponse created = budgetCategoryService.createCategory(user.getId(), categoryRequest);

            BudgetRatioRequest.CategoryRatio ratio = new BudgetRatioRequest.CategoryRatio();
            ratio.setCategoryId(created.getId()); // 방금 만든 카테고리의 id
            ratio.setRatio(item.getRatio());
            ratios.add(ratio);
        }

        // 2) 비율 저장: 합계 100·중복 검증은 saveRatios 안의 기존 로직이 그대로 함
        BudgetRatioRequest ratioRequest = new BudgetRatioRequest();
        ratioRequest.setApplyFrom(YearMonth.now(ZoneId.of("Asia/Seoul")).toString()); // "2026-11"
        ratioRequest.setSavingRatio(request.getSavingRatio());
        ratioRequest.setInvestRatio(request.getInvestRatio());

        ratioRequest.setCategories(ratios);

        budgetRatioService.saveRatios(user.getId(), ratioRequest);

        return user; // 컨트롤러가 이 user의 id로 JWT를 만듦
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