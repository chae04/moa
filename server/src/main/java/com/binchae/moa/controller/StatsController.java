package com.binchae.moa.controller;

import com.binchae.moa.dto.CategoryStatsResponse;
import com.binchae.moa.dto.YearlyStatsResponse;
import com.binchae.moa.service.StatsService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

// [직접 작성] 클래스 어노테이션 3개, 필드 1개, GET 메서드 2개
// 확인할 것	힌트
// 클래스 경로	@RequestMapping("/api/stats")로 공통 부분을 묶습니다.
// 카테고리별 지출	@GetMapping("/categories")로 받고, year와 month를 받아 getCategoryStats를 호출합니다.
// 1년 추이	@GetMapping("/yearly")로 받고, year만 받아 getYearlyStats를 호출합니다.
// 반환	DTO를 그대로 반환하면 200이 나갑니다.

// 주의할 점: 메서드마다 @GetMapping에 경로를 꼭 써야 합니다. 
// 둘 다 @GetMapping만 쓰면 같은 GET /api/stats 주소가 두 번 등록되어, 서버가 시작할 때 Ambiguous mapping 에러가 납니다.

@RestController
@RequestMapping("/api/stats")
@RequiredArgsConstructor
public class StatsController {

    private final StatsService statsService;

    // 카테고리별 지출
    @GetMapping("/categories")
    public CategoryStatsResponse getCategoryStats(
        @AuthenticationPrincipal Long userId,
        @RequestParam int year,
        @RequestParam int month
    ) {
        return statsService.getCategoryStats(userId, year, month);
    }

    // 1년 추이
    @GetMapping("/yearly")
    public YearlyStatsResponse getYearlyStats(
        @AuthenticationPrincipal Long userId,
        @RequestParam int year
    ) {
        return statsService.getYearlyStats(userId, year);
    }
}