package com.carefinder.dto.member;

import lombok.Data;

@Data
public class MemberKakaoDTO {
    private long mno;
    private String id;
    private String pw;
    private String kakaoId;
    private String email;
    private String name;
    private String gender;
    private String phonenumber;
    private String birth;
    private int age;
}
