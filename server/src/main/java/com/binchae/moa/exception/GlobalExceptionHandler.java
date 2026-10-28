package com.binchae.moa.exception;

import com.binchae.moa.dto.ErrorResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.http.HttpStatus;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(ApiException.class)
    public ResponseEntity<ErrorResponse> handleApiException(ApiException e) {
        return ResponseEntity
                .status(e.getStatus())
                .body(new ErrorResponse(e.getMessage()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidation(MethodArgumentNotValidException e) {
        // 첫 번째 검증 실패 메시지를 꺼내 400으로 응답
        return ResponseEntity
                .status(HttpStatus.BAD_REQUEST)
                .body(new ErrorResponse(e.getBindingResult().getFieldError().getDefaultMessage()));
    }
}