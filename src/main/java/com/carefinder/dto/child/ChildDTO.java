package com.carefinder.dto.child;

import lombok.Data;

@Data
public class ChildDTO {
    private Integer childId;
    private Long mno;

    private String childName;

    private String birth;
    private String gender;
}