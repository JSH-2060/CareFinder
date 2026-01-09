package com.carefinder.dto.bmi;

import lombok.Data;

@Data
public class ChildBmiPercentileDTO {

    private String gender;     // M / F
    private int ageMonth;      // 개월
    private double p5;         // 5%
    private double p85;        // 85%
    private double p95;        // 95%
}
