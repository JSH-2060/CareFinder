package com.carefinder.dao.member;

import org.apache.ibatis.annotations.Mapper;
import com.carefinder.dto.member.NaverDTO; // ★ member 패키지 확인

@Mapper
public interface NaverDAO {
    // 1. 네이버 ID로 회원 찾기
    NaverDTO selectByNaverId(String naver_id);

    // 2. 이메일로 회원 찾기
    NaverDTO selectByEmail(String email);

    // 3. 신규 회원가입
    void insertNaverMember(NaverDTO dto);

    // 4. 회원 정보 수정
    void updateNaverMember(NaverDTO dto);
}