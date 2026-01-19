package com.carefinder.controller.mypage;

import com.carefinder.dto.member.MemberAccountDTO;
import com.carefinder.service.member.MemberAccountService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
@RequestMapping("/mypage")
@RequiredArgsConstructor
public class MyPageController {

    private final MemberAccountService memberAccountService;

    /* 마이페이지 메인 화면 */
    @GetMapping("")
    public String mypage(HttpSession session, Model model) {

        Long mno = (Long) session.getAttribute("userPk");
        if (mno == null) {
            return "redirect:/Nologin";
        }

        MemberAccountDTO accountDTO =
                memberAccountService.getAccountInfo(mno);

        model.addAttribute("name", accountDTO.getName());
        model.addAttribute("email", accountDTO.getEmail());
        model.addAttribute("phonenumber", accountDTO.getPhonenumber());

        return "mypage/mypage";
    }

    /* 마이페이지 정보 수정 */
    @PostMapping("/update")
    public String updateMyInfo(
            @RequestParam String name,
            @RequestParam String phonenumber,
            HttpSession session
    ) {
        Long mno = (Long) session.getAttribute("userPk");
        if (mno == null) {
            return "redirect:/Nologin";
        }

        // 숫자만 남기기
        String onlyNumber = phonenumber.replaceAll("[^0-9]", "");

        // 11자리 검증
        if (!onlyNumber.matches("^01[0-9]{9}$")) {

            return "redirect:/mypage?error=phone";
        }

        // 하이픈 포맷 (010-1234-5678)
        String formattedPhone =
                onlyNumber.replaceFirst("(\\d{3})(\\d{4})(\\d{4})", "$1-$2-$3");

        MemberAccountDTO dto = new MemberAccountDTO();
        dto.setMno(mno);
        dto.setName(name);
        dto.setPhonenumber(formattedPhone);

        memberAccountService.updateAccountInfo(dto);


        session.setAttribute("userName", name);


        return "redirect:/";
    }

    /* 회원 탈퇴 */
    @GetMapping("/withdraw")
    public String withdraw(HttpSession session) {

        Long mno = (Long) session.getAttribute("userPk");
        if (mno == null) {
            return "redirect:/Nologin";
        }

        memberAccountService.withdraw(mno);

        // 세션 종료 (로그아웃)
        session.invalidate();

        return "redirect:/";
    }
}