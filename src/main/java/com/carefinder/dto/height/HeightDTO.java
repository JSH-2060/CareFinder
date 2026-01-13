package com.carefinder.dto.height;

import lombok.Data;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class HeightDTO {

    private Long heightId;
    private Long mno;          // ✅ 추가
    private Integer childId;
    private Double height;
    private LocalDate recordDate;
    private LocalDateTime createdAt;
}
