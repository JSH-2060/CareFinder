package com.carefinder.controller.register;

import com.carefinder.dto.member.MemberRegisterDTO;
import com.carefinder.service.register.RegisterService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model; // Model 임포트 추가
import org.springframework.web.bind.annotation.*;

@Controller
@RequiredArgsConstructor
@RequestMapping("/member")
public class RegisterController {

    private final RegisterService registerService;

    // 1. 회원가입 페이지
    @GetMapping("/join")
    public String joinForm() {
        return "register/join";
    }

    // 2. 아이디 중복 체크
    @GetMapping("/checkId")
    @ResponseBody
    public String checkId(@RequestParam("id") String id) {
        boolean isDuplicate = registerService.isIdDuplicate(id);
        return isDuplicate ? "1" : "0";
    }

    // 3. 회원가입 처리
    @PostMapping("/join")
    public String join(@ModelAttribute MemberRegisterDTO member, Model model) {


        String result = registerService.registerNormalMember(member);

        // 가입 성공 시
        if ("success".equals(result)) {
            return "redirect:/Nologin";
        }

        // 가입 실패 시 (휴대폰 번호 오류 등)
        else {

            model.addAttribute("msg", result);
            member.setPhonenumber("");
            model.addAttribute("member", member);

            return "register/join";
        }
    }
}