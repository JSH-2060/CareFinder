package com.carefinder.controller.mypage;

import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
@RequestMapping("/mypage")
public class MyPageController {

    @GetMapping("")
    public String mypage(HttpSession session, Model model) {

        Long mno = (Long) session.getAttribute("userPk");
        if (mno == null) return "redirect:/Nologin";

        Member member = memberService.findByMno(mno);

        model.addAttribute("name", member.getName());
        model.addAttribute("email", member.getEmail());
        model.addAttribute("phonenumber", member.getPhonenumber());

        return "mypage/mypage";
    }

    @PostMapping("/update")
    public String updateInfo(
            @RequestParam String name,
            @RequestParam String phonenumber,
            HttpSession session) {

        Long mno = (Long) session.getAttribute("userPk");
        if (mno == null) return "redirect:/Nologin";

        memberService.updateMyInfo(mno, name, phonenumber);

        // 세션 동기화 (헤더 이름 바로 반영)
        session.setAttribute("userName", name);

        return "redirect:/mypage";
    }
}
