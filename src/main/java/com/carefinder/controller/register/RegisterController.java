package com.carefinder.controller.register;

import com.carefinder.dto.member.MemberRegisterDTO;
import com.carefinder.service.register.RegisterService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

@Controller
@RequiredArgsConstructor
@RequestMapping("/member")
public class RegisterController {

    private final RegisterService registerService;

    // 회원가입 페이지
    @GetMapping("/join")
    public String joinForm() {
        return "register/join";
    }

    // 회원가입 처리
    @PostMapping("/join")
    public String join(MemberRegisterDTO member) {

        boolean result = registerService.registerNormalMember(member);

        if (!result) {
            return "redirect:/member/join?error";
        }
        return "redirect:/";
    }
}
