package com.carefinder.service.register;

import com.carefinder.dto.member.MemberRegisterDTO;

public interface RegisterService {

    String registerNormalMember(MemberRegisterDTO member);

    MemberRegisterDTO loginNormalMember(String id, String pw);

    boolean isIdDuplicate(String id);
}
