package com.binchae.moa.service;

import com.binchae.moa.dto.CategoryRequest;
import com.binchae.moa.dto.CategoryResponse;
import com.binchae.moa.entity.BudgetCategory;
import com.binchae.moa.entity.User;
import com.binchae.moa.exception.ApiException;
import com.binchae.moa.repository.BudgetCategoryRepository;
import com.binchae.moa.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class BudgetCategoryService {

    private static final int MAX_SHOW_ON_HOME = 5;

    private final BudgetCategoryRepository budgetCategoryRepository;
    private final UserRepository userRepository;
    private final BudgetRatioService budgetRatioService;

    // 목록 조회
    @Transactional(readOnly = true)
    public List<CategoryResponse> getCategories(Long userId) {
        User user = findUser(userId);
        return budgetCategoryRepository.findActiveCategories(user).stream()
                .map(CategoryResponse::from)
                .toList();
    }

    // 추가
    @Transactional
    public CategoryResponse createCategory(Long userId, CategoryRequest request) {
        User user = findUser(userId);

        if (request.getShowOnHome()
                && budgetCategoryRepository.countShownOnHome(user) >= MAX_SHOW_ON_HOME) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "홈 표시는 최대 5개까지 가능합니다.");
        }

        BudgetCategory category = new BudgetCategory();
        category.setUser(user);
        category.setName(request.getName());
        category.setShowOnHome(request.getShowOnHome());
        category.setIncludeInDaily(request.getIncludeInDaily());
        category.setOrderIndex(budgetCategoryRepository.findMaxOrderIndex(user) + 1);

        return CategoryResponse.from(budgetCategoryRepository.save(category));
    }

    // 수정
    @Transactional
    public CategoryResponse updateCategory(Long userId, Long categoryId, CategoryRequest request) {
        User user = findUser(userId);
        BudgetCategory category = findOwnedCategory(categoryId, user);

        // 홈 표시 최대 5개 검증
        if (request.getShowOnHome() && !category.getShowOnHome()
                && budgetCategoryRepository.countShownOnHome(user) >= MAX_SHOW_ON_HOME) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "홈 표시는 최대 5개까지 가능합니다.");
        }

        category.setName(request.getName());
        category.setShowOnHome(request.getShowOnHome());
        category.setIncludeInDaily(request.getIncludeInDaily());

        return CategoryResponse.from(category);
    }

    // 삭제 (소프트 삭제)
    @Transactional
    public void deleteCategory(Long userId, Long categoryId) {
        User user = findUser(userId);
        BudgetCategory category = findOwnedCategory(categoryId, user);

        // 최소 1개 유지 검증
        if (budgetCategoryRepository.countActive(user) <= 1) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "카테고리는 최소 1개 존재해야 합니다.");
        }

        // [직접 작성 3] 비율이 남아 있으면 삭제 차단
        if(budgetRatioService.isCategoryInUse(category, user)) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "해당 카테고리에 남아있는 비율을 먼저 조정해야합니다.");
        }

        category.setIsDeleted(true);
    }

    private User findUser(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "사용자를 찾을 수 없습니다."));
    }

    private BudgetCategory findOwnedCategory(Long categoryId, User user) {
        return budgetCategoryRepository.findActiveByIdAndUser(categoryId, user)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "카테고리를 찾을 수 없습니다."));
    }
}