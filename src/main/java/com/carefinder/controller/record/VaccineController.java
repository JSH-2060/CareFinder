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
        if (dto.getChildId() != null && dto.getChildId() == 0) {
            dto.setChildId(null);
        }
        vaccineService.addVaccine(dto);
        rttr.addAttribute("childId", (dto.getChildId() == null) ? 0 : dto.getChildId());
        rttr.addAttribute("childName", dto.getChildName());
        return "redirect:/vaccine/list";
    }

    @PostMapping("/update")
    public String update(VaccineDTO dto, HttpSession session, RedirectAttributes rttr) {
        Long mno = getUserPk(session);
        dto.setMno(mno);
        if (dto.getChildId() != null && dto.getChildId() == 0) {
            dto.setChildId(null);
        }
        vaccineService.updateVaccine(dto);
        rttr.addAttribute("childId", (dto.getChildId() == null) ? 0 : dto.getChildId());
        rttr.addAttribute("childName", dto.getChildName());
        return "redirect:/vaccine/list";
    }

    @GetMapping("/delete")
    public String delete(@RequestParam("vaccineNo") Long vaccineNo,
                         @RequestParam("childId") Integer childId,
                         @RequestParam("childName") String childName, RedirectAttributes rttr) {
        vaccineService.deleteVaccine(vaccineNo);
        rttr.addAttribute("childId", childId);
        rttr.addAttribute("childName", childName);
        return "redirect:/vaccine/list";
    }

    // ★ [핵심 수정] 토글 기능이 작동 안 했던 이유를 해결했습니다.
    @GetMapping("/complete")
    public String complete(@RequestParam("vaccineNo") Long vaccineNo,
                           @RequestParam("childId") Integer childId,
                           @RequestParam("childName") String childName,
                           RedirectAttributes rttr) {

        // 1. 현재 상태 확인
        VaccineDTO vaccine = vaccineService.getVaccine(vaccineNo);

        // 2. 상태에 따라 확실한 메서드 호출 (XML updateStatus 사용)
        if ("Y".equals(vaccine.getStatus())) {
            // 이미 접종완료 상태면 -> 취소(미접종) 처리
            vaccineService.cancelVaccination(vaccineNo);
        } else {
            // 미접종 상태면 -> 접종완료 처리
            vaccineService.completeVaccination(vaccineNo);
        }

        rttr.addAttribute("childId", childId);
        rttr.addAttribute("childName", childName);

        return "redirect:/vaccine/list";
    }

    @GetMapping("/select")
    public String select(HttpSession session, Model model) {

        Long mno = getUserPk(session);
        if (mno == null) return "redirect:/Nologin";

        model.addAttribute("childList", vaccineService.getChildList(mno));

        // ★ JSP에 bmi 모드 전달
        model.addAttribute("mode", "bmi");

        return "heat/childSelect";
    }

}