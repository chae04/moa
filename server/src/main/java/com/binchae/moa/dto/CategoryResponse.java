package com.binchae.moa.dto;

import com.binchae.moa.entity.BudgetCategory;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class CategoryResponse {

    private Long id;
    private String name;
    private Integer orderIndex;
    private Boolean includeInDaily;
    private Boolean showOnHome;

    public static CategoryResponse from(BudgetCategory category) {
        return new CategoryResponse(
                category.getId(),
                category.getName(),
                category.getOrderIndex(),
                category.getIncludeInDaily(),
                category.getShowOnHome()
        );
    }
}
