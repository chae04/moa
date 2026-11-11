package com.binchae.moa.repository;

import com.binchae.moa.entity.Transaction;
import com.binchae.moa.entity.User;
import com.binchae.moa.dto.CategoryStatsResponse;
import com.binchae.moa.dto.MonthlyTypeSum;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface TransactionRepository extends JpaRepository<Transaction, Long> {
    @Query("""
            SELECT t FROM Transaction t
            LEFT JOIN FETCH t.budgetCategory
            WHERE t.user = :user AND t.date BETWEEN :start AND :end
            ORDER BY t.date DESC, t.id DESC
            """)
    List<Transaction> findByUserAndDateRange(
            @Param("user") User user,
            @Param("start") LocalDate start,
            @Param("end") LocalDate end);

    @Modifying
    @Query("delete from Transaction t where t.user = :user") // user의 거래 전체 삭제
    void deleteByUser(@Param("user") User user);

    // 남의 거래는 조회X
    @Query("SELECT t FROM Transaction t WHERE t.id = :id AND t.user = :user")
    Optional<Transaction> findByIdAndUser(@Param("id") Long id, @Param("user") User user);

    // 수입에서 만들어진 자동 거래들을 찾음. 수입 날짜를 바꿀 때 사용.
    @Query("SELECT t FROM Transaction t WHERE t.sourceTransactionId = :sourceId")
    List<Transaction> findBySourceTransactionId(@Param("sourceId") Long sourceId);

    @Modifying
    // 수입을 지울 때 자동 거래를 한 번에 지움.
    @Query("delete from Transaction t where t.sourceTransactionId = :sourceId")
    void deleteBySourceTransactionId(@Param("sourceId") Long sourceId);

    // 기간 안 지출을 카테고리별로 합산. 금액 큰 순.
    @Query("""
            SELECT new com.binchae.moa.dto.CategoryStatsResponse$CategoryAmount(t.category, SUM(t.amount))
            FROM Transaction t
            WHERE t.user = :user AND t.type = '지출' AND t.date BETWEEN :start AND :end
            GROUP BY t.category
            ORDER BY SUM(t.amount) DESC
            """)
    List<CategoryStatsResponse.CategoryAmount> sumExpenseByCategory(
            @Param("user") User user,
            @Param("start") LocalDate start,
            @Param("end") LocalDate end);

    // [직접 작성] 기간 안 수입·지출을 월별, 유형별로 합산
    @Query("""
            SELECT new com.binchae.moa.dto.MonthlyTypeSum(MONTH(t.date), t.type, SUM(t.amount))
            From Transaction t
            WHERE t.user = :user AND t.type IN ('수입', '지출') AND t.date BETWEEN :start AND :end
            GROUP BY MONTH(t.date), t.type
            """)
    List<MonthlyTypeSum> sumByMonthAndType(
            @Param("user") User user,
            @Param("start") LocalDate start,
            @Param("end") LocalDate end);
}