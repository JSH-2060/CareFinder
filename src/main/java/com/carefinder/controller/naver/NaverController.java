package com.carefinder.controller.naver;

import jakarta.servlet.http.HttpSession;
import com.carefinder.service.naver.NaverService;
import com.carefinder.dto.member.NaverDTO; // ★ member 패키지 확인
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.UUID;

@Controller
public class NaverController {

    @Autowired private NaverService naverService;
    @Autowired private PasswordEncoder passwordEncoder;

    @GetMapping("/nlogin")
    public String nlogin(HttpSession session) {
        return "redirect:" + naverService.getAuthorizationUrl(session);
    }

    @GetMapping("/callback")
    public String callback(@RequestParam(required = false) String code,
                           @RequestParam(required = false) String state,
                           @RequestParam(required = false) String error,
                           HttpSession session, Model model) {

        if (error != null) {
            model.addAttribute("msg", "네이버 로그인이 취소되었습니다.");
            model.addAttribute("url", "/Nologin");
            return "common/alert";
        }

        String token = naverService.getAccessToken(code, state);
        if (token == null) return "redirect:/Nologin";

        // ★ 여기서도 dto.naver... 라고 적힌거 수정함
        NaverDTO naverDTO = naverService.getUserProfile(token);
        if (naverDTO == null) return "redirect:/Nologin";

        naverDTO.setPassword(passwordEncoder.encode(UUID.randomUUID().toString()));

        // ★ 여기도 수정
        NaverDTO loginMember = naverService.loginOrJoin(naverDTO);

        if (loginMember != null) {
            session.setAttribute("userPk", loginMember.getMno());
            session.setAttribute("userName", loginMember.getName());
            session.setAttribute("loginType", "NAVER");
            return "redirect:/";
        } else {
            return "redirect:/Nologin";
        }
    }

    @GetMapping("/nlogout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/";
    }
}