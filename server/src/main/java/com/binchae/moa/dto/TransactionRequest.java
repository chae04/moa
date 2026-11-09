package com.binchae.moa.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
public class TransactionRequest {

    @NotBlank(message = "거래명을 입력해주세요.")
    @Size(max = 10, message = "거래명이 너무 깁니다.")
    private String title;

    @NotNull(message = "금액을 입력해주세요.")
    @Positive(message = "금액은 0보다 커야 합니다.")    // Positive : 0과 음수를 막음
    private Integer amount;

    @NotBlank(message = "거래 유형을 입력해주세요.")
    @Pattern(regexp = "수입|지출|저축|투자", message = "거래 유형은 수입, 지출, 저축, 투자 중 하나여야 합니다.")
    private String type;

    @Size(max = 10, message = "카테고리가 너무 깁니다.")
    private String category;

    private Long budgetCategoryId;

    @NotNull(message = "날짜를 입력해주세요.")
    private LocalDate date;

    @Size(max = 255, message = "메모가 너무 깁니다.")
    private String memo;
}