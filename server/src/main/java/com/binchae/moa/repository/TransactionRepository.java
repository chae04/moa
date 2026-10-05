package com.binchae.moa.repository;

import com.binchae.moa.entity.Transaction;
import com.binchae.moa.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDate;
import java.util.List;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface TransactionRepository extends JpaRepository<Transaction, Long> {
    @Query("""
            SELECT t FROM Transaction t 
            WHERE t.user = :user AND t.date BETWEEN :start AND :end 
            ORDER BY t.date DESC
            """)
    List<Transaction> findByUserAndDateRange(@Param("user") User user, @Param("start") LocalDate start, @Param("end") LocalDate end);
}