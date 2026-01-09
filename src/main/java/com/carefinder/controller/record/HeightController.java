package com.carefinder.controller.record;

import com.carefinder.dto.height.HeightDTO;
import com.carefinder.service.height.HeightService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/height")
@RequiredArgsConstructor
public class HeightController {

    private final HeightService heightService;

    /**
     * 키 성장 목록
     * 대상 선택 페이지에서 진입
     */
    @GetMapping("/list")
    public String list(
            @RequestParam int childId,
            @RequestParam String childName,
            Model model
    ) {
        model.addAttribute("childId", childId);
        model.addAttribute("childName", childName);
        model.addAttribute("list", heightService.getList(childId));

        return "height/heightList";
    }

    @GetMapping("/form")
    public String form(
            @RequestParam int childId,
            @RequestParam String childName,
            Model model
    ) {
        model.addAttribute("childId", childId);
        model.addAttribute("childName", childName);
        return "height/heightForm";
    }

    /**
     * 키 기록 추가
     */
    @PostMapping("/add")
    public String add(HeightDTO dto,
                      @RequestParam String childName) {

        heightService.add(dto);

        return "redirect:/height/list?childId="
                + dto.getChildId()
                + "&childName="
                + childName;
    }

    /**
     * 키 기록 수정
     */
    @PostMapping("/update")
    public String update(HeightDTO dto,
                         @RequestParam String childName) {

        heightService.update(dto);

        return "redirect:/height/list?childId="
                + dto.getChildId()
                + "&childName="
                + childName;
    }

    /**
     * 키 기록 삭제
     */
    @PostMapping("/delete")
    public String delete(@RequestParam Long heightId,
                         @RequestParam int childId,
                         @RequestParam String childName) {

        heightService.delete(heightId);

        return "redirect:/height/list?childId="
                + childId
                + "&childName="
                + childName;
    }
}