package com.carefinder.dto.bmi;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@NoArgsConstructor
@AllArgsConstructor
@Data
public class BmiCriteriaDTO {
    private int bmiId;
    private String gender;
    private int minAge;
    private int maxAge;

    private double underBmi;
    private double normalBmi;
    private double obeseBmi;
    private double severeBmi;

}
