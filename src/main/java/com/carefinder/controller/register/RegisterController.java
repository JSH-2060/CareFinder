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

    // 2. 아이디 중복 체크 (기존 유지)
    @GetMapping("/checkId")
    @ResponseBody
    public String checkId(@RequestParam("id") String id) {
        boolean isDuplicate = registerService.isIdDuplicate(id);
        return isDuplicate ? "1" : "0";
    }

    // 3. 회원가입 처리 (수정됨)
    @PostMapping("/join")
    public String join(@ModelAttribute MemberRegisterDTO member, Model model) {

        // 서비스가 'boolean' 대신 'String' 메시지를 반환하도록 수정했다고 가정
        // (성공하면 "success", 실패하면 "에러메시지")
        String result = registerService.registerNormalMember(member);

        // 가입 성공 시
        if ("success".equals(result)) {
            return "redirect:/Nologin";
        }

        // 가입 실패 시 (휴대폰 번호 오류 등)
        else {
            // 1. 화면에 띄울 경고 메시지 전달
            model.addAttribute("msg", result);

            // 2. "휴대폰 번호만 다시 적게" 하기 위해 휴대폰 번호 필드 초기화
            member.setPhonenumber("");

            // 3. 나머지 입력 정보(아이디, 이름 등)는 유지되도록 다시 전달
            model.addAttribute("member", member);

            // 4. redirect가 아니라 JSP 파일 경로를 바로 리턴 (데이터 유지됨)
            return "register/join";
        }
    }
}