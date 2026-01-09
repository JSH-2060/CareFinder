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

    private String googleId;   // ⭐ 추가
    private String kakaoId;
    private String naverId;

    private Integer age;
    private String gender;
    private String phonenumber;
    private String birth;

    // getter / setter
}
