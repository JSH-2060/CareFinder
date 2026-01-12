package com.carefinder.dto.vaccine;

import lombok.Data;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;

@Data
public class VaccineDTO {
    private Long vaccineNo;
    private Long mno;
    private Integer childId;
    private String childName;
    private String vaccineName;
    private Integer chasu;
    private String inoculationDate; // YYYY-MM-DD
    private String status;          // Y or N
    private Long dayDiff;       // 접종여부 (Y/N)

    // ★ D-Day 계산 로직 (JSP에서 편하게 쓰기 위해 DTO에 기능 추가)
    // inoculationDate를 기준으로 오늘과의 날짜 차이를 계산
    public long getDayDiff() {
        if (inoculationDate == null || inoculationDate.isEmpty()) return 0;
        try {
            LocalDate planDate = LocalDate.parse(inoculationDate, DateTimeFormatter.ISO_DATE);
            LocalDate today = LocalDate.now();
            return ChronoUnit.DAYS.between(today, planDate);
        } catch (Exception e) {
            return 0;
        }
    }
}