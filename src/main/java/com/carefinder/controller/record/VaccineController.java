package com.carefinder.controller.record;

import com.carefinder.dto.child.ChildDTO;
import com.carefinder.dto.vaccine.VaccineDTO;
import com.carefinder.service.vaccine.VaccineService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

@Controller
@RequestMapping("/vaccine")
@RequiredArgsConstructor
public class VaccineController {

    private final VaccineService vaccineService;

    private Long getUserPk(HttpSession session) {
        Object pk = session.getAttribute("userPk");
        return (pk != null) ? Long.valueOf(String.valueOf(pk)) : null;
    }

    @GetMapping("/list")
    public String list(HttpSession session, Model model,
                       @RequestParam(value = "childId", defaultValue = "0") Integer childId,
                       @RequestParam(value = "childName", required = false) String childName) {
        Long mno = getUserPk(session);
        if (mno == null) return "redirect:/Nologin";

        // ★ 자녀 목록 (Service에 메서드 추가 필수)
        List<ChildDTO> childList = vaccineService.getChildList(mno);
        model.addAttribute("childList", childList);

        List<VaccineDTO> list = vaccineService.getVaccineList(mno, childId);
        model.addAttribute("list", list);
        model.addAttribute("childId", childId);
        model.addAttribute("childName", (childName == null || childName.isEmpty()) ? "나" : childName);

        return "vaccine/vaccineList";
    }

    @PostMapping("/add")
    public String add(VaccineDTO dto, HttpSession session, RedirectAttributes rttr) {
        Long mno = getUserPk(session);
        dto.setMno(mno);

        // ★ 본인(0)이면 DB에 NULL로 저장
        if (dto.getChildId() != null && dto.getChildId() == 0) {
            dto.setChildId(null);
        }

        vaccineService.addVaccine(dto);

        Integer redirectId = (dto.getChildId() == null) ? 0 : dto.getChildId();
        rttr.addAttribute("childId", redirectId);
        rttr.addAttribute("childName", dto.getChildName());
        return "redirect:/vaccine/list";
    }

    // update, delete, complete, cancel 메서드는 기존 유지 (childId 파라미터 챙기기)
    @GetMapping("/delete")
    public String delete(@RequestParam("vaccineNo") Long vaccineNo,
                         @RequestParam("childId") Integer childId,
                         @RequestParam("childName") String childName, RedirectAttributes rttr) {
        vaccineService.deleteVaccine(vaccineNo);
        rttr.addAttribute("childId", childId);
        rttr.addAttribute("childName", childName);
        return "redirect:/vaccine/list";
    }
    @GetMapping("/select")
    public String select(HttpSession session, Model model) {
        Long mno = getUserPk(session);
        if (mno == null) return "redirect:/Nologin";

        // 자녀 목록 가져오기
        model.addAttribute("childList", vaccineService.getChildList(mno));

        // ★ 중요: JSP에게 "나는 백신(vaccine)이다"라고 알려줌
        model.addAttribute("mode", "vaccine");

        // 화면은 기존에 만든 childSelect.jsp 재사용
        return "heat/childSelect";
    }
    @GetMapping("/complete")
    public String complete(@RequestParam("vaccineNo") Long vaccineNo,
                           @RequestParam("childId") Integer childId,
                           @RequestParam("childName") String childName,
                           RedirectAttributes rttr) {

        // 서비스 호출해서 상태를 'Y'로 변경
        vaccineService.completeVaccination(vaccineNo);

        // 다시 목록으로 돌아갈 때 정보 유지
        rttr.addAttribute("childId", childId);
        rttr.addAttribute("childName", childName);

        return "redirect:/vaccine/list";
    }
}