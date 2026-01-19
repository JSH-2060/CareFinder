package com.carefinder.controller.child;

import com.carefinder.dto.child.ChildDTO;
import com.carefinder.service.child.ChildService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/child")
@RequiredArgsConstructor
public class ChildController {

    private final ChildService childService;

    private Long getUserPk(HttpSession session) {
        Object pk = session.getAttribute("userPk");
        return (pk != null) ? Long.valueOf(String.valueOf(pk)) : null;
    }

    // 1. 아이 추가 화면
    @GetMapping("/add")
    public String addChildForm(HttpSession session) {
        if (getUserPk(session) == null) return "redirect:/Nologin";
        return "child/childAddForm";
    }

    // 2. 저장 및 실행
    @PostMapping("/add")
    public String addChild(ChildDTO dto, HttpSession session) {
        Long mno = getUserPk(session);
        if (mno == null) return "redirect:/Nologin";

        dto.setMno(mno);

        childService.insertChild(dto);

        return "redirect:/heat/select";
    }

    // 3. 수정 화면
    @GetMapping("/edit")
    public String editChildForm(@RequestParam("childId") Integer childId, Model model, HttpSession session) {
        if (getUserPk(session) == null) return "redirect:/Nologin";
        model.addAttribute("child", childService.getChildById(childId));
        return "child/childAddForm";
    }

    // 4. 수정 및 실행
    @PostMapping("/update")
    public String updateChild(ChildDTO dto, HttpSession session) {
        if (getUserPk(session) == null) return "redirect:/Nologin";
        childService.updateChild(dto);
        return "redirect:/heat/select";
    }

    // 5. 삭제
    @GetMapping("/delete")
    public String deleteChild(@RequestParam("childId") Integer childId, HttpSession session) {
        Object userPk = session.getAttribute("userPk");
        if (userPk == null) return "redirect:/Nologin";

        childService.deleteChild(childId);

        return "redirect:/heat/select";
    }
}