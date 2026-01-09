package com.carefinder.controller.record;

import jakarta.servlet.http.HttpSession;
import com.carefinder.dto.vaccine.VaccineDTO;
import com.carefinder.service.vaccine.VaccineService;
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
        Object pkObj = session.getAttribute("userPk");
        return (pkObj != null) ? Long.valueOf(String.valueOf(pkObj)) : null;
    }

    @GetMapping("/list")
    public String list(HttpSession session, Model model,
                       @RequestParam("childId") Integer childId,
                       @RequestParam(value = "childName", required = false) String childName) {
        Long mno = getUserPk(session);
        if (mno == null) return "redirect:/Nologin";

        List<VaccineDTO> list = vaccineService.getVaccineList(mno, childId);
        model.addAttribute("list", list);
        model.addAttribute("childId", childId);
        model.addAttribute("childName", childName);
        return "vaccine/vaccineList";
    }

    @PostMapping("/add")
    public String add(VaccineDTO dto, HttpSession session, RedirectAttributes rttr) {
        Long mno = getUserPk(session);
        if (mno != null) {
            dto.setMno(mno);
            vaccineService.addVaccine(dto);
        }
        rttr.addAttribute("childId", dto.getChildId());
        rttr.addAttribute("childName", dto.getChildName());
        return "redirect:/vaccine/list";
    }

    @PostMapping("/update")
    public String update(VaccineDTO dto,
                         @RequestParam("childName") String childName, // ★ [추가] 화면에서 보낸 이름을 여기서 받음!
                         RedirectAttributes rttr) {

        // 1. DB 수정 실행
        vaccineService.updateVaccine(dto);

        // 2. 목록으로 돌아갈 때 짐 챙기기 (아이디 + 이름)
        rttr.addAttribute("childId", dto.getChildId());
        rttr.addAttribute("childName", childName); // ★ [핵심] 여기서 이름을 다시 챙겨서 보내야 함!

        return "redirect:/vaccine/list";
    }

    // ★ [핵심 수정] childId를 파라미터로 받아서 그대로 리다이렉트에 사용 (DB조회 X, 안전함)
    @GetMapping("/delete")
    public String delete(@RequestParam("vaccineNo") Long vaccineNo,
                         @RequestParam("childName") String childName,
                         @RequestParam("childId") Integer childId, // 여기 추가됨!
                         RedirectAttributes rttr) {
        vaccineService.deleteVaccine(vaccineNo);
        rttr.addAttribute("childId", childId);
        rttr.addAttribute("childName", childName);
        return "redirect:/vaccine/list";
    }

    // ★ [핵심 수정] childId 추가
    @GetMapping("/complete")
    public String complete(@RequestParam("vaccineNo") Long vaccineNo,
                           @RequestParam("childName") String childName,
                           @RequestParam("childId") Integer childId, // 여기 추가됨!
                           RedirectAttributes rttr) {
        vaccineService.completeVaccination(vaccineNo);
        rttr.addAttribute("childId", childId);
        rttr.addAttribute("childName", childName);
        return "redirect:/vaccine/list";
    }

    // ★ [핵심 수정] childId 추가
    @GetMapping("/cancel")
    public String cancel(@RequestParam("vaccineNo") Long vaccineNo,
                         @RequestParam("childName") String childName,
                         @RequestParam("childId") Integer childId, // 여기 추가됨!
                         RedirectAttributes rttr) {
        vaccineService.cancelVaccination(vaccineNo);
        rttr.addAttribute("childId", childId);
        rttr.addAttribute("childName", childName);
        return "redirect:/vaccine/list";
    }
}