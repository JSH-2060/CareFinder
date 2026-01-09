package com.carefinder.dto.child;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class ChildDTO {
    // DB: int -> Java: Integer
    private Integer childId;

    // DB: bigint -> Java: Long
    private Long mno;

    private String childName;
    private String birth;
    private String gender;   // 'M' or 'F'
    private LocalDateTime createdAt;
}