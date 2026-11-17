package com.binchae.moa.service;

import com.binchae.moa.dto.BudgetRatioRequest;
import com.binchae.moa.dto.BudgetRatioResponse;
import com.binchae.moa.entity.BudgetCategory;
import com.binchae.moa.entity.BudgetRatio;
import com.binchae.moa.entity.User;
import com.binchae.moa.exception.ApiException;
import com.binchae.moa.repository.BudgetCategoryRepository;
import com.binchae.moa.repository.BudgetRatioRepository;
import com.binchae.moa.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.YearMonth;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class BudgetRatioService {

    private static final String MONTH_FORMAT = "\\d{4}-(0[1-9]|1[0-2])";
    private static final ZoneId KOREA = ZoneId.of("Asia/Seoul");

    private final BudgetRatioRepository budgetRatioRepository;
    private final BudgetCategoryRepository budgetCategoryRepository;
    private final UserRepository userRepository;

    // 해당 월에 적용되는 비율 조회
    @Transactional(readOnly = true)
    public BudgetRatioResponse getRatios(Long userId, String month) {
        if (!month.matches(MONTH_FORMAT)) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "조회 월은 YYYY-MM 형식이어야 합니다.");
        }

        User user = findUser(userId);
        String applyFrom = budgetRatioRepository.findLatestApplyFrom(user, month);
        if (applyFrom == null) {
            return new BudgetRatioResponse(null, 0, 0, List.of());
        }

        return toResponse(budgetRatioRepository.findByUserAndApplyFrom(user, applyFrom));
    }

    // 비율 저장 (같은 적용 월이면 교체)
    @Transactional
    public BudgetRatioResponse saveRatios(Long userId, BudgetRatioRequest request) {
        User user = findUser(userId);

        if (request.getApplyFrom().compareTo(currentMonth()) < 0) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "지난 달의 비율은 변경할 수 없습니다.");
        }

        // 합계 100 검증
        int categorySum = request.getCategories().stream()
                .mapToInt(BudgetRatioRequest.CategoryRatio::getRatio)
                .sum();

        int total = categorySum + request.getSavingRatio() + request.getInvestRatio();

        if (total != 100) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "비율 합계는 100이어야 합니다. 현재: " + total);
        }

        long distinctCount = request.getCategories().stream()
                .map(BudgetRatioRequest.CategoryRatio::getCategoryId)
                .distinct()
                .count();
        if (distinctCount != request.getCategories().size()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "같은 카테고리를 중복해서 보낼 수 없습니다.");
        }

        List<BudgetRatio> rows = new ArrayList<>();
        for (BudgetRatioRequest.CategoryRatio item : request.getCategories()) {
            BudgetCategory category = budgetCategoryRepository
                    .findActiveByIdAndUser(item.getCategoryId(), user)
                    .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "카테고리를 찾을 수 없습니다."));

            BudgetRatio row = new BudgetRatio();
            row.setUser(user);
            row.setBudgetCategory(category);
            row.setRatio(item.getRatio());
            row.setApplyFrom(request.getApplyFrom());
            row.setSavingRatio(request.getSavingRatio());
            row.setInvestRatio(request.getInvestRatio());

            rows.add(row);
        }

        budgetRatioRepository.deleteByUserAndApplyFrom(user, request.getApplyFrom());
        budgetRatioRepository.saveAll(rows);

        return toResponse(budgetRatioRepository.findByUserAndApplyFrom(user, request.getApplyFrom()));
    }

    // 현재 또는 앞으로 적용될 비율에 이 카테고리가 쓰이는지 확인
    public boolean isCategoryInUse(BudgetCategory category, User user) {
        String thisMonth = currentMonth();
        String latest = budgetRatioRepository.findLatestApplyFrom(user, thisMonth);
        String from = (latest != null) ? latest : thisMonth;
        return budgetRatioRepository.existsPositiveRatioFrom(category, from);
    }

    private BudgetRatioResponse toResponse(List<BudgetRatio> rows) {
        BudgetRatio first = rows.get(0);

        List<BudgetRatioResponse.CategoryRatio> categories = rows.stream()
                .filter(row -> !(row.getBudgetCategory().getIsDeleted() && row.getRatio() == 0))
                .map(row -> new BudgetRatioResponse.CategoryRatio(
                        row.getBudgetCategory().getId(),
                        row.getBudgetCategory().getName(),
                        row.getRatio()))
                .toList();

        return new BudgetRatioResponse(
                first.getApplyFrom(), first.getSavingRatio(), first.getInvestRatio(), categories);
    }

    private String currentMonth() {
        return YearMonth.now(KOREA).toString();
    }

    private User findUser(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new ApiException(HttpStatus.UNAUTHORIZED, "다시 로그인해주세요."));
    }
}