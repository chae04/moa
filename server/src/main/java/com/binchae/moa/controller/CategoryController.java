package com.binchae.moa.controller;

import com.binchae.moa.dto.CategoryRequest;
import com.binchae.moa.dto.CategoryResponse;
import com.binchae.moa.service.BudgetCategoryService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/categories")
@RequiredArgsConstructor
public class CategoryController {

    private final BudgetCategoryService budgetCategoryService;

    // 목록 조회
    @GetMapping
    public List<CategoryResponse> getCategories(@AuthenticationPrincipal Long userId) {
        return budgetCategoryService.getCategories(userId);
    }

    // 추가
    @PostMapping
    public ResponseEntity<CategoryResponse> createCategory(
            @AuthenticationPrincipal Long userId,
            @Valid @RequestBody CategoryRequest request) {
        CategoryResponse response = budgetCategoryService.createCategory(userId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    // 수정: PUT /api/categories/{id}
    @PutMapping("/{id}")
    public CategoryResponse updateCategory(@PathVariable Long id,
            @AuthenticationPrincipal Long userId,
            @Valid @RequestBody CategoryRequest request) {
        return budgetCategoryService.updateCategory(userId, id, request);
    }

    // 삭제: DELETE /api/categories/{id}
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteCategory(@PathVariable Long id,
            @AuthenticationPrincipal Long userId) {
        budgetCategoryService.deleteCategory(userId, id);
        return ResponseEntity.noContent().build();
    }
}