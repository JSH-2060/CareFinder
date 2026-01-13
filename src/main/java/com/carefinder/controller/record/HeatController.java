package com.carefinder.controller.record;

import com.carefinder.dto.child.ChildDTO;
import com.carefinder.dto.heat.HeatDTO;
import com.carefinder.service.heat.HeatService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

@Controller
@RequestMapping("/heat")
@RequiredArgsConstructor
public class HeatController {

    private final HeatService heatService;

    private Long getUserPk(HttpSession session) {
        Object pk = session.getAttribute("userPk");
        return (pk != null) ? Long.valueOf(String.valueOf(pk)) : null;
    }

    @GetMapping("/list")
    public String list(@RequestParam(value="childId", defaultValue="0") Integer childId,
                       @RequestParam(value="childName", required=false) String childName,
                       HttpSession session, Model model) {
        Long mno = getUserPk(session);
        if (mno == null) return "redirect:/Nologin";

        // 상단 프로필용
        List<ChildDTO> childList = heatService.getChildList(mno);
        model.addAttribute("childList", childList);

        // 기록용
        List<HeatDTO> list = heatService.getHeatListByChild(mno, childId);
        model.addAttribute("list", list);

        model.addAttribute("childId", childId);
        model.addAttribute("childName", (childName == null || childName.isEmpty()) ? "나" : childName);

        return "heat/heatList";
    }

    @PostMapping("/add")
    public String add(HeatDTO dto, HttpSession session) {
        Long mno = getUserPk(session);
        if (mno == null) return "redirect:/Nologin";
        dto.setMno(mno);

        // ★ 본인(0)이면 DB에 NULL로 저장
        if (dto.getChildId() != null && dto.getChildId() == 0) {
            dto.setChildId(null);
        }

        heatService.insertHeat(dto);

        // 리다이렉트
        String redirectId = (dto.getChildId() == null) ? "0" : String.valueOf(dto.getChildId());
        String encodedName = URLEncoder.encode(dto.getChildName(), StandardCharsets.UTF_8);
        return "redirect:/heat/list?childId=" + redirectId + "&childName=" + encodedName;
    }

    @GetMapping("/delete")
    public String delete(@RequestParam("heatNo") Long heatNo,
                         @RequestParam("childId") Integer childId,
                         @RequestParam("childName") String childName) {
        heatService.deleteHeat(heatNo);
        String encodedName = URLEncoder.encode(childName, StandardCharsets.UTF_8);
        return "redirect:/heat/list?childId=" + childId + "&childName=" + encodedName;
    }

    @GetMapping("/select")
    public String select(HttpSession session, Model model) {
        Long mno = getUserPk(session);
        if(mno == null) return "redirect:/Nologin";

        model.addAttribute("childList", heatService.getChildList(mno));

        // ★★★ [추가] 중요: JSP에게 "나는 체온(heat)이다"라고 알려줌
        model.addAttribute("mode", "heat");

        return "heat/childSelect";
    }
    @PostMapping("/update")
    public String updateHeat(HeatDTO dto) {
        heatService.updateHeat(dto);

        String redirectId = (dto.getChildId() == null) ? "0" : String.valueOf(dto.getChildId());
        String encodedName = URLEncoder.encode(dto.getChildName(), StandardCharsets.UTF_8);

        return "redirect:/heat/list?childId=" + redirectId + "&childName=" + encodedName;
    }
}