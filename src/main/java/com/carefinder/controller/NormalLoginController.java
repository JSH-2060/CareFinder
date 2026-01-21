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




        session.setAttribute("userPk", dto.getMno());
        session.setAttribute("userName", dto.getName());
        session.setAttribute("loginType", "일반");
        session.setAttribute("loginUser", dto);

        return "redirect:/";
    }
}