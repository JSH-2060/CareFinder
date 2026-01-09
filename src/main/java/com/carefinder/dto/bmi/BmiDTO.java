package com.carefinder.dto.bmi;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@AllArgsConstructor
@NoArgsConstructor
@Data
public class BmiDTO {

    private Long bmiNo;
    private Long mno;
    private Integer childId;
    private LocalDate birthDate;
    private LocalDateTime recordDate;
    private String gender;
    private Double height;
    private Double weight;
    private int ageMonth; // 만 나이 (개월)
    private Double bmiValue;
    private String result;

    // 화면용 (자동 계산)
    public String getDateStr() {
        if (recordDate == null) return "";
        return recordDate.format(DateTimeFormatter.ofPattern("MM-dd HH:mm"));
    }
}
