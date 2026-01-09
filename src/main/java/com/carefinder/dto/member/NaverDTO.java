package com.carefinder.dto.member;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDate;
import java.time.Period;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class NaverDTO {
    private Long mno;
    private String naver_id;
    private String name;
    private String email;
    private String mobile;
    private String gender;
    private Integer age;
    private String birth;
    private String id;
    private String password;

    public void fillDetails(String naverId, String name, String email, String gender, String mobile, String birthyear, String birthday) {
        this.naver_id = naverId;
        this.id = email;
        this.name = name;
        this.email = email;

        // ★★★ [여기 수정] M이면 male, F면 female로 변환해서 저장 ★★★
        if ("M".equals(gender)) {
            this.gender = "male";
        } else if ("F".equals(gender)) {
            this.gender = "female";
        } else {
            this.gender = "unknown"; // 혹은 null
        }

        // 휴대폰 번호 하이픈(-) 추가
        if (mobile != null) {
            String digits = mobile.replaceAll("[^0-9]", "");
            if (digits.startsWith("82")) digits = "0" + digits.substring(2);
            if (digits.length() == 11) {
                this.mobile = digits.substring(0, 3) + "-" + digits.substring(3, 7) + "-" + digits.substring(7);
            } else {
                this.mobile = digits;
            }
        }

        // 생년월일 합치기
        if (birthyear != null && birthday != null) {
            this.birth = birthyear + birthday.replace("-", "");
        }

        // 나이 계산
        try {
            if (birthyear != null && birthday != null) {
                int year = Integer.parseInt(birthyear);
                int month = Integer.parseInt(birthday.split("-")[0]);
                int day = Integer.parseInt(birthday.split("-")[1]);
                this.age = Period.between(LocalDate.of(year, month, day), LocalDate.now()).getYears();
            } else {
                this.age = 0;
            }
        } catch (Exception e) {
            this.age = 0;
        }
    }
}