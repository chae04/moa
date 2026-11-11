package com.binchae.moa.controller;

import com.binchae.moa.dto.HomeResponse;
import com.binchae.moa.service.HomeService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/home")
@RequiredArgsConstructor
public class HomeController {
    private final HomeService homeService;

    @GetMapping
    public HomeResponse getHome(
        @AuthenticationPrincipal Long userId,
        @RequestParam int year,
        @RequestParam int month
    ) {
        return homeService.getHome(userId, year, month);
    }
    
}
