package com.binchae.moa.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
public class BudgetRatioRequest {

    @NotBlank(message = "적용 시작 월을 입력해주세요.")
    @Pattern(regexp = "\\d{4}-(0[1-9]|1[0-2])", message = "적용 시작 월은 YYYY-MM 형식이어야 합니다.")
    private String applyFrom;

    @NotNull(message = "저축 비율을 입력해주세요.")
    @Min(value = 0, message = "비율은 0 이상이어야 합니다.")
    @Max(value = 100, message = "비율은 100 이하여야 합니다.")
    private Integer savingRatio;

    @NotNull(message = "투자 비율을 입력해주세요.")
    @Min(value = 0, message = "비율은 0 이상이어야 합니다.")
    @Max(value = 100, message = "비율은 100 이하여야 합니다.")
    private Integer investRatio;

    @NotEmpty(message = "카테고리 비율을 입력해주세요.")
    @Valid
    private List<CategoryRatio> categories;

    @Getter
    @Setter
    @NoArgsConstructor
    public static class CategoryRatio {

        @NotNull(message = "카테고리를 선택해주세요.")
        private Long categoryId;

        @NotNull(message = "카테고리 비율을 입력해주세요.")
        @Min(value = 0, message = "비율은 0 이상이어야 합니다.")
        @Max(value = 100, message = "비율은 100 이하여야 합니다.")
        private Integer ratio;
    }
}
