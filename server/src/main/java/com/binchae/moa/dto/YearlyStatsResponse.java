package com.binchae.moa.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.List;

@Getter
@AllArgsConstructor
public class YearlyStatsResponse {

    private Long totalIncome;
    private Long totalExpense;
    private Long totalSaved; // 모은 돈 = 총수입 - 총지출
    private List<MonthSummary> months; // 항상 12개

    // 한 달 요약
    @Getter
    @AllArgsConstructor
    public static class MonthSummary {
        private Integer month;
        private Long income;
        private Long expense;
        private Long saved;
    }
}