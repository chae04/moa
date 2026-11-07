package com.binchae.moa.repository;

import com.binchae.moa.entity.BudgetCategory;
import com.binchae.moa.entity.BudgetRatio;
import com.binchae.moa.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;

import java.util.List;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface BudgetRatioRepository extends JpaRepository<BudgetRatio, Long> {
    @Query("""
            SELECT br FROM BudgetRatio br 
            WHERE br.user = :user AND br.applyFrom <= :month 
            ORDER BY br.applyFrom DESC
            """)
    List<BudgetRatio> findApplicableRatios(@Param("user") User user, @Param("month") String month);

    @Modifying 
    @Query("delete from BudgetRatio u where u.user = :user")
    void deleteByUser(@Param("user") User user);

    @Query("""
            SELECT MAX(br.applyFrom) FROM BudgetRatio br
            WHERE br.user = :user AND br.applyFrom <= :month
            """)
    // 조회 월 이하에서 가장 최근의 적용 월을 찾음. 없으면 null.
    String findLatestApplyFrom(@Param("user") User user, @Param("month") String month);

    @Query("""
            SELECT br FROM BudgetRatio br
            JOIN FETCH br.budgetCategory bc
            WHERE br.user = :user AND br.applyFrom = :applyFrom
            ORDER BY bc.orderIndex ASC
            """)
    List<BudgetRatio> findByUserAndApplyFrom(@Param("user") User user, @Param("applyFrom") String applyFrom);

    @Modifying
    @Query("delete from BudgetRatio br where br.user = :user and br.applyFrom = :applyFrom")
    // 같은 달 비율을 다시 저장하기 전에 기존 묶음을 지움.
    void deleteByUserAndApplyFrom(@Param("user") User user, @Param("applyFrom") String applyFrom);

    @Query("""
            SELECT COUNT(br) > 0 FROM BudgetRatio br
            WHERE br.budgetCategory = :category AND br.ratio > 0 AND br.applyFrom >= :from
            """)
    // 어떤 달 이후로 이 카테고리에 0보다 큰 비율이 있는지 확인. 삭제 검증에 사용.
    boolean existsPositiveRatioFrom(@Param("category") BudgetCategory category, @Param("from") String from);
}