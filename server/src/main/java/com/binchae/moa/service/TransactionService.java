package com.binchae.moa.service;

import com.binchae.moa.dto.TransactionRequest;
import com.binchae.moa.dto.TransactionResponse;
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

import java.time.YearMonth;
import java.util.List;

@Service
@RequiredArgsConstructor
public class TransactionService {

    private static final String INCOME = "수입";
    private static final String SAVING = "저축";
    private static final String INVEST = "투자";

    private final TransactionRepository transactionRepository;
    private final BudgetCategoryRepository budgetCategoryRepository;
    private final BudgetRatioRepository budgetRatioRepository;
    private final UserRepository userRepository;

    // 월별 조회
    @Transactional(readOnly = true)
    public List<TransactionResponse> getMonthlyTransactions(Long userId, int year, int month) {
        if (year < 2000 || year > 2100 || month < 1 || month > 12) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "조회할 연도와 월이 올바르지 않습니다.");
        }

        User user = findUser(userId);
        YearMonth yearMonth = YearMonth.of(year, month);
        return transactionRepository
                .findByUserAndDateRange(user, yearMonth.atDay(1), yearMonth.atEndOfMonth())
                .stream()
                .map(TransactionResponse::from)
                .toList();
    }

    // 추가 (수입이면 저축·투자 자동 생성)
    @Transactional
    public TransactionResponse createTransaction(Long userId, TransactionRequest request) {
        User user = findUser(userId);

        Transaction transaction = new Transaction();
        transaction.setUser(user);
        transaction.setType(request.getType());
        applyRequest(transaction, request, user);

        Transaction saved = transactionRepository.save(transaction);
        if (INCOME.equals(saved.getType())) {
            createAutoTransactions(saved, user);
        }
        return TransactionResponse.from(saved);
    }

    // 수정
    @Transactional
    public TransactionResponse updateTransaction(Long userId, Long transactionId, TransactionRequest request) {
        User user = findUser(userId);
        Transaction transaction = findOwnedTransaction(transactionId, user);

        if (transaction.getSourceTransactionId() != null) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "자동 생성된 거래는 수정할 수 없습니다.");
        }

        // 거래 유형 변경 금지
        if (!transaction.getType().equals(request.getType())) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "기존 거래 유형 변경은 불가합니다.");
        }

        // 수입 금액 수정 금지
        if (INCOME.equals(transaction.getType()) && !transaction.getAmount().equals(request.getAmount())) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "수입 금액 수정은 불가합니다.");
        }

        applyRequest(transaction, request, user);

        // 수입 날짜가 바뀌면 자동 거래 날짜도 같이 이동 (save 없이도 update 실행됨)
        if (INCOME.equals(transaction.getType())) {
            for (Transaction auto : transactionRepository.findBySourceTransactionId(transaction.getId())) {
                auto.setDate(transaction.getDate());
            }
        }
        return TransactionResponse.from(transaction);
    }

    // 삭제
    @Transactional
    public void deleteTransaction(Long userId, Long transactionId) {
        User user = findUser(userId);
        Transaction transaction = findOwnedTransaction(transactionId, user);

        // 수입이면 자동 거래도 삭제
        if (INCOME.equals(transaction.getType())) {
            transactionRepository.deleteBySourceTransactionId(transaction.getId());
        }

        transactionRepository.delete(transaction);
    }

    // 요청 값을 유형별 규칙에 맞게 거래에 넣기
    private void applyRequest(Transaction transaction, TransactionRequest request, User user) {
        String type = transaction.getType();
        transaction.setTitle(request.getTitle());
        transaction.setAmount(request.getAmount());
        transaction.setDate(request.getDate());
        transaction.setMemo(request.getMemo());

        // 저축·투자는 category를 서버가 정함
        if (SAVING.equals(type) || INVEST.equals(type)) {
            transaction.setCategory(type);
        } else {
            if (request.getCategory() == null || request.getCategory().isBlank()) {
                throw new ApiException(HttpStatus.BAD_REQUEST, "카테고리를 입력해주세요.");
            }
            transaction.setCategory(request.getCategory());
        }

        // 수입은 예산 카테고리 없음
        if (INCOME.equals(type)) {
            transaction.setBudgetCategory(null);
            return;
        }

        // 지출·저축·투자는 예산 카테고리(출처) 필수
        Long budgetCategoryId = request.getBudgetCategoryId();
        if (budgetCategoryId == null) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "예산 카테고리를 선택해주세요.");
        }

        // 카테고리가 그대로면 삭제된 카테고리여도 유지
        BudgetCategory current = transaction.getBudgetCategory();
        if (current != null && current.getId().equals(budgetCategoryId)) {
            return;
        }
        transaction.setBudgetCategory(budgetCategoryRepository.findActiveByIdAndUser(budgetCategoryId, user)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "카테고리를 찾을 수 없습니다.")));
    }

    private void createAutoTransactions(Transaction income, User user) {
        String month = YearMonth.from(income.getDate()).toString();
        String applyFrom = budgetRatioRepository.findLatestApplyFrom(user, month);
        if (applyFrom == null) {
            return; // 비율을 아직 설정하지 않음
        }

        BudgetRatio ratio = budgetRatioRepository.findByUserAndApplyFrom(user, applyFrom).get(0);
        createAutoTransaction(income, user, SAVING, ratio.getSavingRatio());
        createAutoTransaction(income, user, INVEST, ratio.getInvestRatio());
    }

    private void createAutoTransaction(Transaction income, User user, String type, int ratio) {
        int amount = (int) Math.round(income.getAmount() * ratio / 100.0);
        if (amount <= 0) {
            return; // 비율이 0이거나 반올림하면 0원
        }

        Transaction auto = new Transaction();
        auto.setUser(user);
        auto.setTitle("자동 " + type);
        auto.setAmount(amount);
        auto.setType(type);
        auto.setCategory(type);
        auto.setDate(income.getDate());
        auto.setMemo("수입의 " + ratio + "% 자동 " + type);
        auto.setSourceTransactionId(income.getId());
        transactionRepository.save(auto);
    }

    private Transaction findOwnedTransaction(Long transactionId, User user) {
        return transactionRepository.findByIdAndUser(transactionId, user)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "거래를 찾을 수 없습니다."));
    }

    private User findUser(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "사용자를 찾을 수 없습니다."));
    }
}