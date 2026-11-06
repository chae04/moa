package com.binchae.moa.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import java.time.LocalDateTime;

@Entity
@Table(name = "budget_ratios")
@Getter
@Setter
@NoArgsConstructor
public class BudgetRatio {
    @Id 
    @GeneratedValue (strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne (fetch = FetchType.LAZY) // LAZY : 필요할 때만 호출
    @JoinColumn (name = "user_id", nullable = false)
    private User user;

    @ManyToOne (fetch = FetchType.LAZY) // LAZY : 필요할 때만 호출
    @JoinColumn (name = "budget_category_id", nullable = false)
    private BudgetCategory budgetCategory;

    @Column (nullable = false)
    private Integer ratio;

    @Column (name = "apply_from", nullable = false)
    private String applyFrom; // "2026-10"

    @Column (name = "saving_ratio", nullable = false)
    private Integer savingRatio = 0;

    @Column  (name = "invest_ratio", nullable = false)
    private Integer investRatio = 0;

    @Column (name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist 
    public void prePersist() {
        this.createdAt = LocalDateTime.now();
    }
}
