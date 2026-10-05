package com.binchae.moa.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import java.time.LocalDateTime;

@Entity
@Table(name = "budget_categories")
@Getter
@Setter
@NoArgsConstructor
public class BudgetCategory {
    @Id 
    @GeneratedValue (strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne (fetch = FetchType.LAZY) // LAZY : 필요할 때만 호출
    @JoinColumn (name = "user_id", nullable = false)
    private User user;

    @Column (nullable = false)
    private String name;

    @Column (name = "order_index", nullable = false)
    private Integer orderIndex;

    @Column (name = "include_in_daily", nullable = false)
    private Boolean includeInDaily = false;

    @Column (name = "show_on_home", nullable = false)
    private Boolean showOnHome = true;

    @Column (name = "is_delete", nullable = false)
    private Boolean isDeleted = false;

    @Column (name = "created_at")
    private LocalDateTime craetedAt;

    @PrePersist 
    public void prePersist() {
        this.craetedAt = LocalDateTime.now();
    }
}
