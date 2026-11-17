// [역할] 이메일 중복 확인 API(GET /api/auth/check-email)의 응답 DTO
// - 응답 예: {"available": true}  → 사용 가능 / {"available": false} → 이미 가입된 이메일
// - 중복이어도 에러가 아니라 "확인 결과"이므로 200으로 응답한다.
package com.binchae.moa.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter              // getAvailable()이 아니라 boolean이라 isAvailable() 생성 → JSON 키는 "available"
@AllArgsConstructor  // new EmailCheckResponse(true) 로 생성
public class EmailCheckResponse {
    private boolean available; // true = 가입 가능
}
