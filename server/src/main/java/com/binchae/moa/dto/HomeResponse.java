package com.binchae.moa.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDate;
import java.util.List;

@Getter
@AllArgsConstructor
public class HomeResponse {

    private Integer totalIncome;
    private Integer totalExpense;
    private Integer totalSaving;
    private Integer totalInvest;
    private List<CategorySummary> categories;
    private List<DailyExpense> dailyExpenses;
    private Integer dailyBudget; // 지난달이거나 비율이 없으면 null

    // 카테고리별 예산·사용액·잔액
    @Getter
    @AllArgsConstructor
    public static class CategorySummary {
        private Long categoryId;
        private String name;
        private Integer budget;
        private Integer used;
        private Integer remaining;
        private Boolean showOnHome;
        private Boolean includeInDaily;
        private Boolean deleted;
    }

    // 날짜별 지출 합계 (달력 표시용)
    @Getter
    @AllArgsConstructor
    public static class DailyExpense {
        private LocalDate date;
        private Integer amount;
    }
}