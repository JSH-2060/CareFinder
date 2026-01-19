package com.carefinder.controller.record;

import com.carefinder.dto.heat.HeatDTO;
import com.carefinder.service.heat.HeatService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;

@Controller
@RequestMapping("/heat")
@RequiredArgsConstructor
public class HeatController {

    private final HeatService heatService;

    private Long getUserPk(HttpSession session) {
        Object pk = session.getAttribute("userPk");
        return (pk != null) ? Long.valueOf(String.valueOf(pk)) : null;
    }
    @GetMapping("/select")
    public String select(HttpSession session, Model model) {
        Long mno = getUserPk(session);
        if (mno == null) return "redirect:/Nologin";

        model.addAttribute("childList", heatService.getChildList(mno));
        model.addAttribute("mode", "heat");

        return "heat/childSelect";
    }


    @GetMapping("/list")
    public String list(@RequestParam(value = "childId", defaultValue = "0") Integer childId,
                       @RequestParam(value = "childName", required = false) String childName,
                       HttpSession session, Model model) {

        Long mno = getUserPk(session);
        if (mno == null) return "redirect:/Nologin";

        model.addAttribute("childList", heatService.getChildList(mno));
        model.addAttribute("list", heatService.getHeatListByChild(mno, childId));
        model.addAttribute("childId", childId);
        model.addAttribute("childName", (childName == null || childName.isEmpty()) ? "나" : childName);

        return "heat/heatList";
    }

    @PostMapping("/add")
    public String add(HeatDTO dto, HttpSession session) {
        Long mno = getUserPk(session);
        if (mno == null) return "redirect:/Nologin";

        dto.setMno(mno);
        dto.setRecordDate(LocalDateTime.now());

        if (dto.getChildId() != null && dto.getChildId() == 0) {
            dto.setChildId(null);
        }

        heatService.insertHeat(dto);

        String redirectId = dto.getChildId() == null ? "0" : String.valueOf(dto.getChildId());
        String encodedName = URLEncoder.encode(dto.getChildName(), StandardCharsets.UTF_8);

        return "redirect:/heat/list?childId=" + redirectId + "&childName=" + encodedName;
    }

    @PostMapping("/update")
    public String update(HeatDTO dto) {
        heatService.updateHeat(dto);

        String redirectId = dto.getChildId() == null ? "0" : String.valueOf(dto.getChildId());
        String encodedName = URLEncoder.encode(dto.getChildName(), StandardCharsets.UTF_8);

        return "redirect:/heat/list?childId=" + redirectId + "&childName=" + encodedName;
    }

    @GetMapping("/delete")
    public String delete(@RequestParam Long heatNo,
                         @RequestParam Integer childId,
                         @RequestParam String childName) {

        heatService.deleteHeat(heatNo);
        String encodedName = URLEncoder.encode(childName, StandardCharsets.UTF_8);

        return "redirect:/heat/list?childId=" + childId + "&childName=" + encodedName;
    }
}
