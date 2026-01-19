package com.carefinder.dto.member;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class GoogleMemberDTO {

    private Long mno;
    private String id;
    private String pw;
    private String name;
    private String email;

    private String googleId;
    private String kakaoId;
    private String naverId;

    private Integer age;
    private String gender;
    private String phonenumber;
    private String birth;


}
