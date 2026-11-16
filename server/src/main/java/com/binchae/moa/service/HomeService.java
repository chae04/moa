package com.binchae.moa.service;

import com.binchae.moa.dto.HomeResponse;
import com.binchae.moa.dto.HomeResponse.CategorySummary;
import com.binchae.moa.entity.BudgetCategory;
import com.binchae.moa.entity.BudgetRatio;
import com.binchae.moa.entity.Transaction;
import com.binchae.moa.entity.User;
import com.binchae.moa.exception.ApiException;
import com.binchae.moa.repository.BudgetCategoryRepository;
import com.binchae.moa.repository.BudgetRatioRepository;
import com.binchae.moa.repository.TransactionRepository;
import com.binchae.moa.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

@Service
@RequiredArgsConstructor
public class HomeService {

    private static final String INCOME = "수입";
    private static final String EXPENSE = "지출";
    private static final String SAVING = "저축";
    private static final String INVEST = "투자";
    private static final ZoneId SEOUL = ZoneId.of("Asia/Seoul");

    private final TransactionRepository transactionRepository;
    private final BudgetCategoryRepository budgetCategoryRepository;
    private final BudgetRatioRepository budgetRatioRepository;
    private final UserRepository userRepository;

    // 홈 요약 조회
    @Transactional(readOnly = true)
    public HomeResponse getHome(Long userId, int year, int month) {
        if (year < 2000 || year > 2100 || month < 1 || month > 12) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "조회할 연도와 월이 올바르지 않습니다.");
        }
        User user = findUser(userId);
        YearMonth yearMonth = YearMonth.of(year, month);

        List<Transaction> transactions = transactionRepository
                .findByUserAndDateRange(user, yearMonth.atDay(1), yearMonth.atEndOfMonth());

        // 1. 거래를 돌며 유형별 합계, 카테고리별 사용액, 날짜별 지출 계산
        int totalIncome = 0, totalExpense = 0, totalSaving = 0, totalInvest = 0;
        Map<Long, Integer> usedByCategory = new HashMap<>();
        Map<LocalDate, Integer> expenseByDate = new TreeMap<>();
        Map<Long, BudgetCategory> categories = new HashMap<>(); // 목록에 넣을 카테고리 (id로 중복 제거)

        for (Transaction t : transactions) {
            switch (t.getType()) {
                case INCOME -> totalIncome += t.getAmount();
                case EXPENSE -> {
                    totalExpense += t.getAmount();
                    expenseByDate.merge(t.getDate(), t.getAmount(), Integer::sum);
                }
                case SAVING -> totalSaving += t.getAmount();
                case INVEST -> totalInvest += t.getAmount();
            }
            // 사용액이 있는 카테고리 (삭제된 것 포함)
            BudgetCategory category = t.getBudgetCategory();
            if (category != null) {
                usedByCategory.merge(category.getId(), t.getAmount(), Integer::sum);
                categories.put(category.getId(), category);
            }
        }

        // 2. 그 달 비율 묶음에서 비율이 0보다 큰 카테고리
        String applyFrom = budgetRatioRepository.findLatestApplyFrom(user, yearMonth.toString());
        Map<Long, Integer> ratioByCategory = new HashMap<>();
        if (applyFrom != null) {
            for (BudgetRatio ratio : budgetRatioRepository.findByUserAndApplyFrom(user, applyFrom)) {
                if (ratio.getRatio() > 0) {
                    BudgetCategory category = ratio.getBudgetCategory();
                    ratioByCategory.put(category.getId(), ratio.getRatio());
                    categories.put(category.getId(), category);
                }
            }
        }

        // 3. 그 달 말일까지 만들어진 활성 카테고리
        LocalDateTime nextMonthStart = yearMonth.plusMonths(1).atDay(1).atStartOfDay();
        for (BudgetCategory category : budgetCategoryRepository.findActiveCategories(user)) {
            if (category.getCreatedAt() == null || category.getCreatedAt().isBefore(nextMonthStart)) {
                categories.put(category.getId(), category);
            }
        }

        int income = totalIncome; // 람다 안에서 쓰려면 값이 바뀌지 않는 변수여야 함
        List<HomeResponse.CategorySummary> summaries = categories.values().stream()
                .sorted(Comparator.comparing(BudgetCategory::getOrderIndex))
                .map(c -> toSummary(c, income, ratioByCategory, usedByCategory))
                .toList();

        List<HomeResponse.DailyExpense> dailyExpenses = new ArrayList<>();
        expenseByDate.forEach((date, amount) -> dailyExpenses.add(new HomeResponse.DailyExpense(date, amount)));

        return new HomeResponse(totalIncome, totalExpense, totalSaving, totalInvest,
                summaries, dailyExpenses, calculateDailyBudget(yearMonth, applyFrom, summaries));
    }

    // 카테고리 하나의 예산·사용액·잔액 (비율 행이 없으면 예산 0)
    private HomeResponse.CategorySummary toSummary(BudgetCategory category, int income,
            Map<Long, Integer> ratioByCategory, Map<Long, Integer> usedByCategory) {
        int ratio = ratioByCategory.getOrDefault(category.getId(), 0);
        int budget = (int) Math.round(income * ratio / 100.0);
        int used = usedByCategory.getOrDefault(category.getId(), 0);
        return new HomeResponse.CategorySummary(category.getId(), category.getName(), budget, used,
                budget - used, category.getShowOnHome(), category.getIncludeInDaily(), category.getIsDeleted());
    }

    // 일일 추천 예산: 활성 includeInDaily 카테고리 잔액 합 ÷ 남은 일수
    private Integer calculateDailyBudget(YearMonth yearMonth, String applyFrom,
            List<HomeResponse.CategorySummary> summaries) {
        if (applyFrom == null) {
            return null; // 비율을 아직 설정하지 않음
        }
        LocalDate today = LocalDate.now(SEOUL);
        YearMonth thisMonth = YearMonth.from(today);
        if (yearMonth.isBefore(thisMonth)) {
            return null; // 지난달은 추천하지 않음
        }

        // [직접 작성 2] 남은 일수 remainingDays
        int remainingDays = yearMonth.equals(thisMonth) ? yearMonth.lengthOfMonth() - today.getDayOfMonth() + 1
                : yearMonth.lengthOfMonth();

        // [직접 작성 3] 잔액 합 remaining
        int remaining = 0;
        for (CategorySummary summary : summaries) {
            if (summary.getIncludeInDaily() && !summary.getDeleted()) {
                remaining += summary.getRemaining();
            }
        }

        if (remaining <= 0) {
            return 0; // 예산 초과
        }
        return (int) Math.round((double) remaining / remainingDays);
    }

    private User findUser(Long userId) {
        return userRepository.findById(userId)
                // 토큰은 유효하지만 주인이 없음(탈퇴) = 인증 실패 → 401 (Flutter는 401이면 로그아웃 처리)
                .orElseThrow(() -> new ApiException(HttpStatus.UNAUTHORIZED, "다시 로그인해주세요."));
    }
}