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
    // 1. BMI 목록 + 그래프
    // ==========================
    @GetMapping("/list")
    public String bmiList(
            @RequestParam("childId") Integer childId,
            @RequestParam(value = "childName", required = false) String childName,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate,
            HttpSession session,
            Model model) {

        Long mno = getUserPk(session);
        if (mno == null) return "redirect:/Nologin";

        List<BmiDTO> list;

        // 날짜 조건 여부
        if (startDate != null && endDate != null &&
                !startDate.isEmpty() && !endDate.isEmpty()) {

            list = bmiService.getBmiListByDate(mno, childId, startDate, endDate);
            model.addAttribute("startDate", startDate);
            model.addAttribute("endDate", endDate);

        } else {
            list = bmiService.getBmiListByChild(mno, childId);
        }

        // 🔥 NPE 완전 차단
        if (list == null) {
            list = new ArrayList<>();
        }


        model.addAttribute("bmiList", list);
        model.addAttribute("graphList", list);
        model.addAttribute("childId", childId);
        model.addAttribute("childName", childName);

        return "bmi/bmiList";
    }

    // ==========================
    // 2. BMI 입력 화면
    // ==========================
    @GetMapping("/form")
    public String bmiForm(
            @RequestParam("childId") Integer childId,
            @RequestParam("childName") String childName,
            HttpSession session,
            Model model) {

        if (getUserPk(session) == null) return "redirect:/Nologin";

        model.addAttribute("childId", childId);
        model.addAttribute("childName", childName);
        return "bmi/bmiForm";
    }

    // ==========================
    // 3. BMI 계산 + 저장
    // ==========================
    @PostMapping("/insert")
    @ResponseBody
    public String bmiInsert(
            BmiDTO dto,
            @RequestParam("childId") Integer childId,
            @RequestParam("childName") String childName,
            HttpSession session) {

        Long mno = getUserPk(session);
        if (mno == null) {
            return "<script>alert('로그인이 필요합니다.'); window.close();</script>";
        }

        dto.setMno(mno);
        dto.setChildId(childId);

        // 계산 + 저장
        bmiService.calculateAndSave(dto, mno);

        // 🔥 부모창 갱신 + 팝업 닫기
        return """
        <script>
            window.opener.location.href =
                '/bmi/list?childId=%d&childName=%s';
            window.close();
        </script>
        """.formatted(childId, childName);
    }

    @GetMapping("/edit")
    public String bmiEditPopup(
            @RequestParam("bmiNo") Long bmiNo,
            HttpSession session,
            Model model) {

        if (getUserPk(session) == null) return "redirect:/Nologin";

        BmiDTO dto = bmiService.getBmiById(bmiNo);
        model.addAttribute("dto", dto);

        return "bmi/bmiEdit";
    }

    @PostMapping("/update")
    @ResponseBody
    public String updateBmi(BmiDTO dto, HttpSession session) {

        if (getUserPk(session) == null) {
            return "<script>alert('로그인 필요'); window.close();</script>";
        }

        bmiService.updateBmi(dto);

        return """
        <script>
            window.opener.location.reload();
            window.close();
        </script>
    """;
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
            RedirectAttributes rttr) {

        if (getUserPk(session) == null) return "redirect:/Nologin";

        bmiService.deleteBmi(bmiNo);

        rttr.addAttribute("childId", childId);
        rttr.addAttribute("childName", childName);
        return "redirect:/bmi/list";
    }
}
