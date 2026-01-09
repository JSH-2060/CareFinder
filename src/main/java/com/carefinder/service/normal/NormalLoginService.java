package com.carefinder.service.normal;

import com.carefinder.dto.member.NormalLoginDTO;

public interface NormalLoginService {
    NormalLoginDTO findByIdPw(String id, String pw);

}
