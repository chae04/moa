package com.binchae.moa.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class CategoryRequest {

    @NotBlank(message = "카테고리 이름을 입력해주세요.")
    @Size(max = 10, message = "카테고리 이름은 10자 이내로 입력해주세요.")
    private String name;

    @NotNull(message = "홈 표시 여부를 입력해주세요.")
    private Boolean showOnHome;

    @NotNull(message = "일일 예산 포함 여부를 입력해주세요.")
    private Boolean includeInDaily;
}
