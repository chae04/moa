package com.binchae.moa.repository;

import com.binchae.moa.entity.BudgetCategory;
import com.binchae.moa.entity.User;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;

import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface BudgetCategoryRepository extends JpaRepository<BudgetCategory, Long> {
        @Query("""
                        SELECT bc FROM BudgetCategory bc
                        WHERE bc.user = :user AND bc.isDeleted = false
                        ORDER BY bc.orderIndex ASC
                        """)
        List<BudgetCategory> findActiveCategories(@Param("user") User user);

        @Modifying
        @Query("delete from BudgetCategory bc where bc.user = :user")
        void deleteByUser(@Param("user") User user);

        @Query("""
                        SELECT bc FROM BudgetCategory bc
                        WHERE bc.id = :id AND bc.user = :user AND bc.isDeleted = false
                        """)
        Optional<BudgetCategory> findActiveByIdAndUser(@Param("id") Long id, @Param("user") User user);

        @Query("""
                        SELECT COUNT(bc) FROM BudgetCategory bc
                        WHERE bc.user = :user AND bc.isDeleted = false
                        """)
        long countActive(@Param("user") User user);

        @Query("""
                        SELECT COUNT(bc) FROM BudgetCategory bc
                        WHERE bc.user = :user AND bc.isDeleted = false AND bc.showOnHome = true
                        """)
        long countShownOnHome(@Param("user") User user);

        @Query("""
                        SELECT COALESCE(MAX(bc.orderIndex), -1) FROM BudgetCategory bc
                        WHERE bc.user = :user
                        """)
        int findMaxOrderIndex(@Param("user") User user);
}