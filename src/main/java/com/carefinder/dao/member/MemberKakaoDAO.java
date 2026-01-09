package com.carefinder.dao.member;

import com.carefinder.dto.member.MemberKakaoDTO;

public interface MemberKakaoDAO {

    MemberKakaoDTO findById(String id);

    MemberKakaoDTO findByKakaoId(String kakaoId);

    void insertMember(MemberKakaoDTO member);

    void insertKakaoMember(MemberKakaoDTO member);
}
