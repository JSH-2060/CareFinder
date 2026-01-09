package com.carefinder.dto.height;

import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class HeightDTO {

    // PK
    private Long heightId;

    // FK (child.childId)
    private Integer childId;

    // 키 (cm)
    private Double height;

    // 측정 날짜
    private LocalDate recordDate;

    // 생성 시각
    private LocalDateTime createdAt;
}
