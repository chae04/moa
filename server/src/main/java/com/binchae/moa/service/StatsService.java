package com.binchae.moa.service;

import com.binchae.moa.dto.CategoryStatsResponse;
import com.binchae.moa.dto.MonthlyTypeSum;
import com.binchae.moa.dto.YearlyStatsResponse;
import com.binchae.moa.entity.User;
import com.binchae.moa.exception.ApiException;
import com.binchae.moa.repository.TransactionRepository;
import com.binchae.moa.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class StatsService {

    private static final String INCOME = "수입";

    private final TransactionRepository transactionRepository;
    private final UserRepository userRepository;

    // 카테고리별 지출 (한 달)
    @Transactional(readOnly = true)
    public CategoryStatsResponse getCategoryStats(Long userId, int year, int month) {
        if (year < 2000 || year > 2100 || month < 1 || month > 12) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "조회할 연도와 월이 올바르지 않습니다.");
        }
        User user = findUser(userId);
        YearMonth yearMonth = YearMonth.of(year, month);

        List<CategoryStatsResponse.CategoryAmount> categories = transactionRepository
                .sumExpenseByCategory(user, yearMonth.atDay(1), yearMonth.atEndOfMonth());

        // 총지출 totalExpense
        long totalExpense = 0;
        for (CategoryStatsResponse.CategoryAmount item : categories) {
            totalExpense += item.getAmount();
        }

        return new CategoryStatsResponse(totalExpense, categories);
    }

    // 1년 추이 (1~12월)
    @Transactional(readOnly = true)
    public YearlyStatsResponse getYearlyStats(Long userId, int year) {
        if (year < 2000 || year > 2100) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "조회할 연도가 올바르지 않습니다.");
        }
        User user = findUser(userId);

        // 칸 번호 = 월. 0번 칸은 안 씀
        long[] income = new long[13];
        long[] expense = new long[13];
        for (MonthlyTypeSum row : transactionRepository.sumByMonthAndType(
                user, LocalDate.of(year, 1, 1), LocalDate.of(year, 12, 31))) {
            if (INCOME.equals(row.getType())) {
                income[row.getMonth()] = row.getAmount();
            } else {
                expense[row.getMonth()] = row.getAmount();
            }
        }

        List<YearlyStatsResponse.MonthSummary> months = new ArrayList<>();
        long totalIncome = 0;
        long totalExpense = 0;
        // 1~12월 MonthSummary 만들기, 총수입·총지출 더하기
        for (int m = 1; m <= 12; m++) {
            months.add(new YearlyStatsResponse.MonthSummary(m, income[m], expense[m], income[m] - expense[m]));
            totalIncome += income[m];
            totalExpense += expense[m];
        }

        return new YearlyStatsResponse(totalIncome, totalExpense, totalIncome - totalExpense, months);
    }

    private User findUser(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new ApiException(HttpStatus.UNAUTHORIZED, "다시 로그인해주세요."));
    }
}