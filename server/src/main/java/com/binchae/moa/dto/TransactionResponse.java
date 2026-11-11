package com.binchae.moa.dto;

import com.binchae.moa.entity.BudgetCategory;
import com.binchae.moa.entity.Transaction;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDate;

@Getter
@AllArgsConstructor
public class TransactionResponse {

    private Long id;
    private String title;
    private Integer amount;
    private String type;
    private String category;
    private Long budgetCategoryId;
    private String budgetCategoryName;
    private LocalDate date;
    private String memo;
    private Long sourceTransactionId;

    public static TransactionResponse from(Transaction transaction) {
        BudgetCategory budgetCategory = transaction.getBudgetCategory();
        return new TransactionResponse(
                transaction.getId(),
                transaction.getTitle(),
                transaction.getAmount(),
                transaction.getType(),
                transaction.getCategory(),
                // 수입과 자동 거래는 카테고리 없음
                budgetCategory != null ? budgetCategory.getId() : null,
                budgetCategory != null ? budgetCategory.getName() : null,
                transaction.getDate(),
                transaction.getMemo(),
                transaction.getSourceTransactionId());
    }
}