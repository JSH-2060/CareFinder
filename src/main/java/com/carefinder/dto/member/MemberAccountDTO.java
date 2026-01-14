package com.carefinder.dto.member;


import lombok.Data;

@Data
public class MemberAccountDTO {

    private Long mno;          // 회원 PK
    private String name;       // 이름 (수정 가능)
    private String email;      // 이메일 (조회 전용)
    private String phonenumber; // 휴대폰 번호 (수정 가능)
}
