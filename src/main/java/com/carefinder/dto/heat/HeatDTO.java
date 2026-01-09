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

    private String memo; // 메모
    private LocalDateTime recordDate; // DB 원본 날짜

    // ★ [핵심] JSP에서 쓸 날짜(MM-dd)를 미리 만들어주는 메서드
    public String getDayStr() {
        if (recordDate == null) return "";
        return recordDate.format(DateTimeFormatter.ofPattern("MM-dd"));
    }

    // ★ [핵심] JSP에서 쓸 시간(HH:mm)을 미리 만들어주는 메서드
    public String getTimeStr() {
        if (recordDate == null) return "";
        return recordDate.format(DateTimeFormatter.ofPattern("HH:mm"));
    }
}