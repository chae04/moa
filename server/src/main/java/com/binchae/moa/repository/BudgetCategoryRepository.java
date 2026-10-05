package com.binchae.moa.repository;

import com.binchae.moa.entity.BudgetCategory;
import com.binchae.moa.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface BudgetCategoryRepository extends JpaRepository<BudgetCategory, Long> {
    @Query("""
            SELECT bc FROM BudgetCategory bc 
            WHERE bc.user = :user AND bc.isDeleted = false 
            ORDER BY bc.orderIndex ASC
            """)
    List<BudgetCategory> findActiveCategories(@Param("user") User user);
}