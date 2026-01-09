package com.carefinder.service.register;

import com.carefinder.dto.member.MemberRegisterDTO;

public interface RegisterService {

    boolean registerNormalMember(MemberRegisterDTO member);

    MemberRegisterDTO loginNormalMember(String id, String pw);

    boolean isIdDuplicate(String id);
}
