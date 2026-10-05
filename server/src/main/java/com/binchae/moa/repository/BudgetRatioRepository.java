package com.binchae.moa.repository;

import com.binchae.moa.entity.BudgetRatio;
import com.binchae.moa.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
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
}