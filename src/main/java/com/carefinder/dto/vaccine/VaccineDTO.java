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
    private String inoculationDate;
    private String status;          // Y or N
    private Long dayDiff;       // 접종여부

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