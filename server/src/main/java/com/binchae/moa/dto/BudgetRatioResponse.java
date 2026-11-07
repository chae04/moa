package com.binchae.moa.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.List;

@Getter
@AllArgsConstructor
public class BudgetRatioResponse {

    private String applyFrom;
    private Integer savingRatio;
    private Integer investRatio;
    private List<CategoryRatio> categories;

    @Getter
    @AllArgsConstructor
    public static class CategoryRatio {
        private Long categoryId;
        private String name;
        private Integer ratio;
    }
}