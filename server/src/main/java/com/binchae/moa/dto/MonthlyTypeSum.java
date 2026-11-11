package com.binchae.moa.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

// 1년 추이 쿼리 결과 한 줄: (월, 유형, 합계)
@Getter
@AllArgsConstructor
public class MonthlyTypeSum {
    private Integer month;
    private String type;
    private Long amount;
}