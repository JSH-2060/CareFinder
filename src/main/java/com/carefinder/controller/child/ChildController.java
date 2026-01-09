package com.carefinder.controller.child;

import jakarta.servlet.http.HttpSession;
import com.carefinder.dto.child.ChildDTO;
import com.carefinder.service.child.ChildService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
@RequestMapping("/child")
@RequiredArgsConstructor
public class ChildController {

    private final ChildService childService;

    // 공통: 세션 PK 가져오기
    private Long getUserPk(HttpSession session) {
        Object pkObj = session.getAttribute("userPk");
        if (pkObj == null) return null;
        try {
            return Long.valueOf(String.valueOf(pkObj));
        } catch (NumberFormatException e) {
            return null;
        }
    }

    // 1. 사람 추가 페이지 보여주기 (GET)
    @GetMapping("/add")
    public String addChildForm(HttpSession session) {
        if (getUserPk(session) == null) return "redirect:/Nologin";
        return "child/childForm"; // JSP 파일 이름
    }

    // 2. 사람 저장하기 (POST)
    @PostMapping("/add")
    public String addChild(ChildDTO dto, HttpSession session) {
        Long mno = getUserPk(session);
        if (mno == null) return "redirect:/Nologin";

        dto.setMno(mno); // 부모 번호 세팅
        childService.insertChild(dto);

        // 저장이 끝나면 다시 '대상 선택' 화면으로 이동
        return "redirect:/heat/select";
    }

    // ★★★ [이 부분이 없어서 404 오류가 난 겁니다] ★★★
    // 3. [수정 페이지 이동] 기존 정보를 불러와서 폼에 뿌려줌
    @GetMapping("/edit")
    public String editChildForm(@RequestParam("childId") Integer childId, HttpSession session, Model model) {
        if (getUserPk(session) == null) return "redirect:/Nologin";

        // 서비스에서 아이 정보 가져오기
        ChildDTO child = childService.getChildById(childId);

        // 가져온 정보를 화면(JSP)에 "child"라는 이름으로 던져줌
        model.addAttribute("child", child);

        return "child/childForm"; // 추가할 때 썼던 그 폼을 재활용 (데이터가 채워져서 나옴)
    }

    // 4. [수정 실행]
    @PostMapping("/update")
    public String updateChild(ChildDTO dto, HttpSession session) {
        Long mno = getUserPk(session);
        if (mno == null) return "redirect:/Nologin";

        dto.setMno(mno);
        childService.updateChild(dto);

        return "redirect:/heat/select";
    }

    // 5. [삭제 실행]
    @GetMapping("/delete")
    public String deleteChild(@RequestParam("childId") Integer childId, HttpSession session) {
        if (getUserPk(session) == null) return "redirect:/Nologin";

        childService.deleteChild(childId);

        return "redirect:/heat/select";
    }
}