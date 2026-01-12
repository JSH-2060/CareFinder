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
            @RequestParam(value = "childId", required = false) Integer childId,
            @RequestParam(value = "childName", required = false) String childName,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate,
            HttpSession session,
            Model model) {

        Long mno = getUserPk(session);
        if (mno == null) return "redirect:/Nologin";

        // =========================
        // ✅ [추가 1] childId 기본값 처리 (나)
        // =========================
        if (childId == null) {
            childId = 0;
            childName = (String) session.getAttribute("userName");
        }

        // =========================
        // ✅ [추가 2] 자녀 목록 (프로필 버튼용)
        // =========================
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

        if (list == null) {
            list = new ArrayList<>();
        }

        // =========================
        // ✅ [추가 3] 최근 BMI (기준 바용)
        // =========================
        BmiDTO latestBmi = bmiService.getLatestBmi(childId);

        // =========================
        // model 전달
        // =========================
        model.addAttribute("bmiList", list);
        model.addAttribute("graphList", list);   // 기존 유지
        model.addAttribute("latestBmi", latestBmi);

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

        // ✅ 최근 BMI 기록 조회 (추가)
        BmiDTO latestBmi = bmiService.getLatestBmi(childId);

        model.addAttribute("childId", childId);
        model.addAttribute("childName", childName);
        model.addAttribute("latestBmi", latestBmi); // ✅ 추가

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

        // =========================
        // ✅ 핵심: DB 저장용 childId 처리
        // =========================
        if (childId != null && childId == 0) {
            dto.setChildId(null);   // DB에는 NULL
        } else {
            dto.setChildId(childId);
        }

        // 계산 + 저장
        bmiService.calculateAndSave(dto, mno);

        // =========================
        // 🔥 화면용 childId는 그대로 0 유지
        // =========================
        return """
    <script>
        window.opener.location.href =
            '/bmi/list?childId=%d&childName=%s';
        window.close();
    </script>
    """.formatted(childId, childName);
    }


    @GetMapping("/select")
    public String select(HttpSession session, Model model) {
        Long mno = getUserPk(session);
        if (mno == null) return "redirect:/Nologin";

        // 자녀 목록 가져오기
        model.addAttribute("childList", bmiService.getChildList(mno));

        // ★ 중요: JSP에게 "나는 BMI(bmi)다"라고 알려줌
        model.addAttribute("mode", "bmi");

        // 기존 childSelect.jsp 재사용
        return "heat/childSelect";
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
