package com.carefinder.dto.member;

import lombok.Data;

@Data
public class MemberRegisterDTO {

    private Long mno;
    private String id;
    private String pw;
    private String name;

    //  이메일
    private String email;
    private String emailId;      // 이메일 앞부분
    private String emailDomain;  // @naver.com 등

    //  나이
    private Integer age;
    private String birth;        // yyyy-MM-dd

    private String gender;
    private String phonenumber;
}
