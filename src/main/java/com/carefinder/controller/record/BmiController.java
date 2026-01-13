package com.carefinder.controller.record;

import jakarta.servlet.http.HttpSession;
import com.carefinder.dto.bmi.BmiDTO;
import com.carefinder.service.bmi.BmiService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@Controller
@RequestMapping("/bmi")
@RequiredArgsConstructor
public class BmiController {

    private final BmiService bmiService;

    // ==========================
    // 공통: 로그인 PK
    // ==========================
    private Long getUserPk(HttpSession session) {
        Object pk = session.getAttribute("userPk");
        return (pk != null) ? Long.valueOf(String.valueOf(pk)) : null;
    }

    // ==========================
    // 1. BMI 목록
    // ==========================
    @GetMapping("/list")
    public String bmiList(
            @RequestParam(value = "childId", required = false) Integer childId,
            @RequestParam(value = "childName", required = false) String childName,
            @RequestParam(value = "startDate", required = false) String startDate,
            @RequestParam(value = "endDate", required = false) String endDate,
            HttpSession session,
            Model model
    ) {

        Long mno = getUserPk(session);
        if (mno == null) return "redirect:/Nologin";

        if (childId == null) {
            childId = 0;
            childName = (String) session.getAttribute("userName");
        }

        model.addAttribute("childList", bmiService.getChildList(mno));

        List<BmiDTO> list;
        if (startDate != null && endDate != null &&
                !startDate.isEmpty() && !endDate.isEmpty()) {

            list = bmiService.getBmiListByDate(mno, childId, startDate, endDate);
            model.addAttribute("startDate", startDate);
            model.addAttribute("endDate", endDate);

        } else {
            list = bmiService.getBmiListByChild(mno, childId);
        }

        if (list == null) list = new ArrayList<>();

        BmiDTO latestBmi = bmiService.getLatestBmi(mno, childId);

        model.addAttribute("bmiList", list);
        model.addAttribute("graphList", list);
        model.addAttribute("latestBmi", latestBmi);
        model.addAttribute("childId", childId);
        model.addAttribute("childName", childName);

        return "bmi/bmiList";
    }

    // ==========================
    // 2. BMI 저장
    // ==========================
    @PostMapping("/insert")
    public String bmiInsert(
            BmiDTO dto,
            @RequestParam("childId") Integer childId,
            @RequestParam("childName") String childName,
            HttpSession session,
            RedirectAttributes rttr
    ) {

        Long mno = getUserPk(session);
        if (mno == null) return "redirect:/Nologin";

        dto.setMno(mno);

        if (childId != null && childId == 0) {
            dto.setChildId(null);
        } else {
            dto.setChildId(childId);
        }

        bmiService.calculateAndSave(dto, mno);

        rttr.addAttribute("childId", childId);
        rttr.addAttribute("childName", childName);

        return "redirect:/bmi/list";
    }

    // ==========================
    // 3. BMI 수정
    // ==========================
    @PostMapping("/update")
    public String updateBmi(
            BmiDTO dto,
            @RequestParam("childId") Integer childId,
            @RequestParam("childName") String childName,
            HttpSession session,
            RedirectAttributes rttr
    ) {

        if (getUserPk(session) == null) return "redirect:/Nologin";

        bmiService.updateBmi(dto);

        rttr.addAttribute("childId", childId);
        rttr.addAttribute("childName", childName);

        return "redirect:/bmi/list";
    }

    // ==========================
    // 4. BMI 삭제
    // ==========================
    @PostMapping("/delete")
    public String deleteBmi(
            @RequestParam("bmiNo") Long bmiNo,
            @RequestParam("childId") Integer childId,
            @RequestParam("childName") String childName,
            HttpSession session,
            RedirectAttributes rttr
    ) {

        if (getUserPk(session) == null) return "redirect:/Nologin";

        bmiService.deleteBmi(bmiNo);

        rttr.addAttribute("childId", childId);
        rttr.addAttribute("childName", childName);

        return "redirect:/bmi/list";
    }
    // ==========================
    // 7. 대상 선택 (Height 방식 재사용)
    // ==========================
    @GetMapping("/select")
    public String select(HttpSession session, Model model) {

        Long mno = getUserPk(session);
        if (mno == null) return "redirect:/Nologin";

        model.addAttribute("childList", bmiService.getChildList(mno));

        // ★ JSP에 bmi 모드 전달
        model.addAttribute("mode", "bmi");

        return "heat/childSelect";
    }

}
