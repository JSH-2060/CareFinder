package com.carefinder.dto.member;

import lombok.Data;

import java.time.LocalDate;

@Data
public class MemberProfileDTO {
    private Long mno;
    private LocalDate birth;
    private String gender;
}
