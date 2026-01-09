package com.carefinder.dto.member;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class NormalLoginDTO {
    
    private long mno;
    private String id;
    private String pw;
    private String name;
    private String email;
    private int age;
    private String gender;
    private String phonenumber;
    private String birth;

}
