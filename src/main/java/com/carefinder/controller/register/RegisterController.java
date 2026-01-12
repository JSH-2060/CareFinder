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

    // 1. 회원가입 페이지 (기존 유지)
    @GetMapping("/join")
    public String joinForm() {
        // 형님 파일 경로가 "register/join.jsp" 라면 이대로 두세요.
        return "register/join";
    }

    @GetMapping("/checkId")
    @ResponseBody
    public String checkId(@RequestParam("id") String id) {
        boolean isDuplicate = registerService.isIdDuplicate(id);

        if (isDuplicate) {
            return "1"; // 중복됨 (빨간불)
        } else {
            return "0"; // 사용 가능 (초록불)
        }
    }

    // 3. 회원가입 처리 (기존 유지)
    @PostMapping("/join")
    public String join(MemberRegisterDTO member) {
        boolean result = registerService.registerNormalMember(member);
        if (!result) {
            return "redirect:/member/join?error";
        }
        return "redirect:/Nologin"; // 가입 성공 시 로그인 페이지로
    }
}