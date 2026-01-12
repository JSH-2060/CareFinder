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
    private String memo; // 이거 없으면 에러남

    private LocalDateTime recordDate; // DB용
    private String measureDateTime;   // 화면용

    // ★★★ [핵심] 이 메서드가 없으면 기록 저장이 절대 안 됩니다! ★★★
    public void setMeasureDateTime(String measureDateTime) {
        this.measureDateTime = measureDateTime;
        if (measureDateTime != null && !measureDateTime.isEmpty()) {
            try {
                // "2026-01-09 18:00" -> "2026-01-09T18:00:00" 변환
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