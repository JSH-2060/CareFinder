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
    private Boolean adult;
    private Double bmiPercent;

    //  BMI 기준 표시용
    private Double cut1;
    private Double cut2;
    private Double cut3;
    private Double cut4; // 성인만 사용 (고도비만 기준)


    // 화면용
    public String getDateStr() {
        if (recordDate == null) return "";
        return recordDate.format(DateTimeFormatter.ofPattern("MM-dd HH:mm"));
    }
}
