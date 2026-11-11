package com.binchae.moa.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "transactions")
@Getter
@Setter
@NoArgsConstructor
public class Transaction {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY) // LAZY : 필요할 때만 호출
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private String title;

    @Column(nullable = false)
    private Integer amount;

    @Column(nullable = false)
    private String type; // 수입, 지출, 저축, 투자

    @Column(nullable = false)
    private String category;

    @ManyToOne(fetch = FetchType.LAZY) // LAZY : 필요할 때만 호출
    @JoinColumn(name = "budget_category_id")
    private BudgetCategory budgetCategory;

    @Column(nullable = false)
    private LocalDate date;

    private String memo; // null 허용

    @Column(name = "source_transaction_id")
    private Long sourceTransactionId; // 자동 거래를 만든 수입의 id. 그 외에는 null

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    public void prePersist() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    public void preUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}
