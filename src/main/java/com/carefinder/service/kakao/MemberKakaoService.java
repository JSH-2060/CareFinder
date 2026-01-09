package com.carefinder.service.kakao;

import com.carefinder.dto.member.MemberKakaoDTO;

import java.util.Map;

public interface MemberKakaoService {

    MemberKakaoDTO kakaoLogin(Map<String, Object> kakaoUser);

    MemberKakaoDTO login(String id, String pw);

    void join(MemberKakaoDTO member);
}
