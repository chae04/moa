package com.binchae.moa.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.List;

@Getter
@AllArgsConstructor
public class CategoryStatsResponse {

    private Long totalExpense;
    private List<CategoryAmount> categories; // 금액 큰 순

    // 지출 카테고리 하나의 합계 (쿼리 결과를 바로 담음)
    @Getter
    @AllArgsConstructor
    public static class CategoryAmount {
        private String category;
        private Long amount;
    }
}