package com.carefinder.dto.heat;

import lombok.Data;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Data
public class HeatDTO {
    private Long heatNo;
    private Long mno;
    private Integer childId;
    private String childName;
    private Double temperature;
    private String memo;

    private LocalDateTime recordDate; // DB 용
    private String measureDateTime;   // 화면용

    public void setMeasureDateTime(String measureDateTime) {
        this.measureDateTime = measureDateTime;
        if (measureDateTime != null && !measureDateTime.isEmpty()) {
            try {
                // 시간 변환
                String iso = measureDateTime.replace(" ", "T") + ":00";
                this.recordDate = LocalDateTime.parse(iso);
            } catch (Exception e) {
                this.recordDate = LocalDateTime.now();
            }
        }
    }

    public String getMeasureDate() {
        return (recordDate != null) ? recordDate.format(DateTimeFormatter.ofPattern("yyyy-MM-dd")) : "";
    }

    public String getMeasureTime() {
        return (recordDate != null) ? recordDate.format(DateTimeFormatter.ofPattern("HH:mm")) : "";
    }
}