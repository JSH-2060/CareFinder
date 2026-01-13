package com.carefinder.controller.record;

import jakarta.servlet.http.HttpSession;
import com.carefinder.dto.height.HeightDTO;
import com.carefinder.service.height.HeightService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Controller
@RequestMapping("/height")
@RequiredArgsConstructor
public class HeightController {

    private final HeightService heightService;

    // ==========================
    // 공통: 로그인 PK
    // ==========================
    private Long getUserPk(HttpSession session) {
        Object pk = session.getAttribute("userPk");
        return (pk != null) ? Long.valueOf(String.valueOf(pk)) : null;
    }

    // ==========================
    // 1. 키 성장 목록 + 그래프
    // ==========================
    @GetMapping("/list")
    public String heightList(
            @RequestParam(value = "childId", required = false) Integer childId,
            @RequestParam(value = "childName", required = false) String childName,
            @RequestParam(value = "startDate", required = false) String startDate,
            @RequestParam(value = "endDate", required = false) String endDate,
            HttpSession session,
            Model model
    ) {

        Long mno = getUserPk(session);
        if (mno == null) return "redirect:/Nologin";

        // ✅ BMI와 동일: childId 기본값 (본인)
        if (childId == null) {
            childId = 0;
            childName = (String) session.getAttribute("userName");
        }

        List<HeightDTO> list =
                heightService.getList(mno, childId, startDate, endDate);

        if (list == null) list = new ArrayList<>();

        HeightDTO latest = null;
        if (!list.isEmpty()) {
            latest = list.get(0); // 최신
        }

        model.addAttribute("latestHeight", latest);

        model.addAttribute("list", list);
        model.addAttribute("graphList", list);

        model.addAttribute("childList", heightService.getChildList(mno));
        model.addAttribute("childId", childId);
        model.addAttribute("childName", childName);

        // 🔥 날짜 유지
        model.addAttribute("startDate", startDate);
        model.addAttribute("endDate", endDate);

        return "height/heightList";
    }

    // ==========================
    // 2. 키 입력 화면 (팝업)
    // ==========================
    @GetMapping("/form")
    public String heightForm(
            @RequestParam("childId") Integer childId,
            @RequestParam("childName") String childName,
            HttpSession session,
            Model model
    ) {

        if (getUserPk(session) == null) return "redirect:/Nologin";

        model.addAttribute("childId", childId);
        model.addAttribute("childName", childName);

        return "height/heightForm";
    }

    // ==========================
    // 3. 키 기록 저장
    // ==========================
    @PostMapping("/insert")
    public String insertHeight(
            HeightDTO dto,
            @RequestParam("childId") Integer childId,
            @RequestParam("childName") String childName,
            HttpSession session,
            RedirectAttributes rttr
    ) {
        Long mno = getUserPk(session);
        if (mno == null) return "redirect:/Nologin";

        // 🔥 키 범위 검증
        if (dto.getHeight() == null
                || dto.getHeight() < 80
                || dto.getHeight() > 250) {

            rttr.addAttribute("childId", childId);
            rttr.addAttribute("childName", childName);
            rttr.addFlashAttribute("msg", "키는 80~250cm 사이만 입력 가능합니다.");

            return "redirect:/height/list";
        }

        dto.setMno(mno);

        if (childId != null && childId == 0) {
            dto.setChildId(null);
        } else {
            dto.setChildId(childId);
        }

        heightService.insert(dto);

        rttr.addAttribute("childId", childId);
        rttr.addAttribute("childName", childName);

        return "redirect:/height/list";
    }

    // ==========================
    // 4. 키 수정 팝업
    // ==========================
    @GetMapping("/edit")
    public String heightEdit(
            @RequestParam("heightId") Long heightId,
            HttpSession session,
            Model model
    ) {

        if (getUserPk(session) == null) return "redirect:/Nologin";

        HeightDTO dto = heightService.getById(heightId);
        model.addAttribute("dto", dto);

        return "height/heightEdit";
    }

    // ==========================
    // 5. 키 수정 처리
    // ==========================
    @PostMapping("/update")
    public String updateHeight(
            HeightDTO dto,
            HttpSession session,
            RedirectAttributes rttr
    ) {
        if (getUserPk(session) == null) {
            return "redirect:/Nologin";
        }

        // 🔥 키 범위 검증
        if (dto.getHeight() == null
                || dto.getHeight() < 80
                || dto.getHeight() > 250) {

            rttr.addFlashAttribute("msg", "키는 80~250cm 사이만 입력 가능합니다.");
            return "redirect:/height/list";
        }

        heightService.update(dto);

        return "redirect:/height/list";
    }

    // ==========================
    // 6. 키 삭제
    // ==========================
    @PostMapping("/delete")
    public String deleteHeight(
            @RequestParam("heightId") Long heightId,
            @RequestParam("childId") Integer childId,
            @RequestParam("childName") String childName,
            HttpSession session,
            RedirectAttributes rttr
    ) {

        if (getUserPk(session) == null) return "redirect:/Nologin";

        heightService.delete(heightId);

        rttr.addAttribute("childId", childId);
        rttr.addAttribute("childName", childName);

        return "redirect:/height/list";
    }

    // ==========================
    // 7. 대상 선택 (BMI 방식 재사용)
    // ==========================
    @GetMapping("/select")
    public String select(HttpSession session, Model model) {

        Long mno = getUserPk(session);
        if (mno == null) return "redirect:/Nologin";

        model.addAttribute("childList", heightService.getChildList(mno));

        // ★ JSP에 height 모드 전달
        model.addAttribute("mode", "height");

        return "heat/childSelect";
    }
}
