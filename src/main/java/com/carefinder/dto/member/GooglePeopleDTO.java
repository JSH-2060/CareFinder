package com.carefinder.dto.member;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class GooglePeopleDTO {

    private String gender;
    private Integer age;
    private String phonenumber;
    private String birth;
}
