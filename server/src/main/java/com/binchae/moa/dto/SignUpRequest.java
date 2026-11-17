package com.binchae.moa.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
public class SignUpRequest {

    @NotBlank
    @Email
    private String email;

    @NotBlank
    @Size(min = 6)
    private String password;

    // ---- 가입과 함께 저장할 첫 비율 (적용 시작 월은 서버가 이번 달로 정함) ----

    @NotNull(message = "저축 비율을 입력해주세요.")
    @Min(value = 0, message = "비율은 0 이상이어야 합니다.")
    @Max(value = 100, message = "비율은 100 이하여야 합니다.")
    private Integer savingRatio;

    @NotNull(message = "투자 비율을 입력해주세요.")
    @Min(value = 0, message = "비율은 0 이상이어야 합니다.")
    @Max(value = 100, message = "비율은 100 이하여야 합니다.")
    private Integer investRatio;

    @NotEmpty(message = "카테고리를 1개 이상 입력해주세요.") // null과 빈 리스트 [] 둘 다 막음
    @Valid // 리스트 안의 각 CategoryItem에 붙은 검증도 실행하라는 뜻 (없으면 안쪽 검증은 무시됨)
    private List<CategoryItem> categories;

    // 가입 때 만들 카테고리 하나 (이름 + 일일 포함 여부 + 비율)
    // static: 바깥 객체 없이 Jackson이 단독으로 생성할 수 있어야 해서 필요
    @Getter
    @Setter
    @NoArgsConstructor
    public static class CategoryItem {

        // CategoryRequest와 같은 이름 규칙
        @NotBlank(message = "카테고리 이름을 입력해주세요.")
        @Size(max = 10, message = "카테고리 이름은 10자 이내로 입력해주세요.")
        private String name;

        @NotNull(message = "일일 예산 포함 여부를 입력해주세요.")
        private Boolean includeInDaily;

        @NotNull(message = "카테고리 비율을 입력해주세요.")
        @Min(value = 0, message = "비율은 0 이상이어야 합니다.")
        @Max(value = 100, message = "비율은 100 이하여야 합니다.")
        private Integer ratio;
    }
}
