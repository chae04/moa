package com.binchae.moa.controller;

import com.binchae.moa.dto.TransactionRequest;
import com.binchae.moa.dto.TransactionResponse;
import com.binchae.moa.service.TransactionService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/transactions")
@RequiredArgsConstructor
public class TransactionController {

    private final TransactionService transactionService;

    // 월별 조회: GET /api/transactions?year=2026&month=11
    @GetMapping
    public List<TransactionResponse> getTransactions(
            @AuthenticationPrincipal Long userId,
            @RequestParam int year,
            @RequestParam int month) {
        return transactionService.getMonthlyTransactions(userId, year, month);
    }

    // 추가
    @PostMapping
    public ResponseEntity<TransactionResponse> createTransaction(
            @AuthenticationPrincipal Long userId,
            @Valid @RequestBody TransactionRequest request) {
        TransactionResponse response = transactionService.createTransaction(userId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    // 수정: PUT /api/transactions/{id}
    @PutMapping("/{id}")
    public TransactionResponse updateTransaction(
            @PathVariable Long id,
            @AuthenticationPrincipal Long userId,
            @Valid @RequestBody TransactionRequest request) {
        return transactionService.updateTransaction(userId, id, request);
    }

    // 삭제: DELETE /api/transactions/{id}
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTransaction(
            @PathVariable Long id,
            @AuthenticationPrincipal Long userId) {
        transactionService.deleteTransaction(userId, id);
        return ResponseEntity.noContent().build();
    }
}