// [역할] 내 정보 조회 API(GET /api/users/me)의 응답 DTO
// - 응답 예: {"email": "test@test.com"}
// - 엔티티(User)를 그대로 응답하지 않고 필요한 필드만 골라 담는다. (password 해시가 밖으로 나가지 않게)
// - 마이페이지에 표시할 정보가 늘어나면(가입일 등) 여기에 필드를 추가한다.
package com.binchae.moa.dto;

import com.binchae.moa.entity.User;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter              // getEmail() 생성 → Jackson이 JSON 키 "email"로 사용
@AllArgsConstructor  // new UserResponse(email)
public class UserResponse {
    private String email;

    // 엔티티 → DTO 변환. Service에서 UserResponse.from(user) 로 사용
    public static UserResponse from(User user) {
        return new UserResponse(user.getEmail());
    }
}
