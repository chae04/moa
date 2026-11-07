package com.binchae.moa.controller;

import com.binchae.moa.dto.BudgetRatioRequest;
import com.binchae.moa.dto.BudgetRatioResponse;
import com.binchae.moa.service.BudgetRatioService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;


@RestController
@RequestMapping("/api/budget-ratios")
@RequiredArgsConstructor
public class BudgetRatioController {

    private final BudgetRatioService budgetRatioService;

    // 해당 월에 적용되는 비율 조회
    @GetMapping
    public BudgetRatioResponse getRatios(
            @AuthenticationPrincipal Long userId,
            @RequestParam String month) {
        return budgetRatioService.getRatios(userId, month);
    }

    // 저장
    @PutMapping
    public BudgetRatioResponse saveRatios(@AuthenticationPrincipal Long userId,
            @Valid @RequestBody BudgetRatioRequest request) {
        return budgetRatioService.saveRatios(userId, request);
    }
}