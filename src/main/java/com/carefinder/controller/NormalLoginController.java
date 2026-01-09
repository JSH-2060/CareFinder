package com.carefinder.controller;

import jakarta.servlet.http.HttpSession;
import com.carefinder.dto.member.NormalLoginDTO;
import com.carefinder.service.normal.NormalLoginService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@RequiredArgsConstructor
@Controller
public class NormalLoginController {

    private final NormalLoginService loginService;

    @GetMapping("/Nologin")
    public String nomallogin() {
        return "normal_login/nologin";
    }

    @PostMapping("/Nologin")
    public String nomallogingo(@RequestParam("id") String id,
                               @RequestParam("pw") String pw,
                               HttpSession session) {

        NormalLoginDTO dto = loginService.findByIdPw(id, pw);

        if (dto == null) {
            return "redirect:/Nologin?error=fail";
        }

        // ✅ [세션 통일] 다른 소셜 로그인과 똑같이 맞춰줍니다.

        // 1. 핵심 PK (DB 조회용)
        session.setAttribute("userPk", dto.getMno());

        // 2. 사용자 이름 (index.jsp 헤더 표시용: ${userName})
        session.setAttribute("userName", dto.getName());

        // 3. 로그인 타입 (index.jsp 헤더 표시용: 일반/카카오/네이버)
        session.setAttribute("loginType", "일반");

        // 4. 전체 정보 (필요 시 사용)
        session.setAttribute("loginUser", dto);

        return "redirect:/";
    }
}