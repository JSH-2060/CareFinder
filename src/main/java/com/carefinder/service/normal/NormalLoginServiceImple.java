package com.carefinder.service.normal;

import com.carefinder.dao.member.NormalLoginDAO;
import com.carefinder.dto.member.NormalLoginDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
@RequiredArgsConstructor
@Service
public class NormalLoginServiceImple implements NormalLoginService {

    private final NormalLoginDAO dao;
    private final org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder passwordEncoder;

    @Override
    public NormalLoginDTO findByIdPw(String id, String pw) {

        NormalLoginDTO dto = dao.findById(id);
        if (dto == null) return null;

        if (!passwordEncoder.matches(pw, dto.getPw())) {
            return null;
        }

        return dto;
    }
}
