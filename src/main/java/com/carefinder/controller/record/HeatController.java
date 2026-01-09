package com.carefinder.controller.record;

import jakarta.servlet.http.HttpSession;
import com.carefinder.dto.child.ChildDTO;
import com.carefinder.dto.heat.HeatDTO;
import com.carefinder.service.heat.HeatService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

@Controller
@RequestMapping("/heat")
@RequiredArgsConstructor
public class HeatController {

    private final HeatService heatService;

    // 세션 PK 가져오기
    private Long getUserPk(HttpSession session) {
        Object pkObj = session.getAttribute("userPk");
        return (pkObj != null) ? Long.valueOf(String.valueOf(pkObj)) : null;
    }

    // 1. 자녀 선택 페이지
    @GetMapping("/select")
    public String selectChild(HttpSession session, Model model) {
        Long mno = getUserPk(session);
        if (mno == null) return "redirect:/Nologin";

        List<ChildDTO> childList = heatService.getChildList(mno);
        model.addAttribute("childList", childList);

        return "heat/childSelect"; // 사용자님의 선택 화면
    }

    // 2. 체온 기록 리스트
    @GetMapping("/list")
    public String list(@RequestParam("childId") Integer childId,
                       @RequestParam(value = "childName", required = false) String childName,
                       HttpSession session, Model model) {

        Long mno = getUserPk(session);
        if (mno == null) return "redirect:/Nologin";

        List<HeatDTO> list = heatService.getHeatListByChild(mno, childId);

        // ★ [삭제됨] 여기서 for문 돌면서 setDateStr 하던 코드는 이제 필요 없습니다!
        // DTO 내부에서 getDayStr(), getTimeStr()가 자동으로 처리합니다.

        model.addAttribute("targetName", childName);
        model.addAttribute("heatList", list);
        model.addAttribute("graphList", list);
        model.addAttribute("childId", childId);

        return "heat/heatList";
    }

    // 3. [팝업] 기록 추가 화면 보여주기
    @GetMapping("/heatupload")
    public String heatUploadPopup(@RequestParam("childId") Integer childId,
                                  @RequestParam("childName") String childName,
                                  Model model) {
        model.addAttribute("childId", childId);
        model.addAttribute("childName", childName);
        return "heat/heatupload";
    }

    // 4. [팝업] 기록 저장 처리
    @PostMapping("/heatupload")
    @ResponseBody
    public String heatUploadAction(HeatDTO dto, HttpSession session) {
        Long mno = getUserPk(session);
        if (mno == null) return "<script>alert('로그인 필요'); window.close();</script>";

        dto.setMno(mno);
        heatService.insertHeat(dto);

        return "<script>alert('저장되었습니다.'); window.opener.location.reload(); window.close();</script>";
    }

    // 5. [팝업] 수정 화면 띄우기
    @GetMapping("/heatedit")
    public String heatEditPopup(@RequestParam("heatNo") Long heatNo, Model model) {
        HeatDTO dto = heatService.getHeatById(heatNo);
        model.addAttribute("dto", dto);
        return "heat/heatedit";
    }

    // 6. [팝업] 수정 처리
    @PostMapping("/update")
    @ResponseBody
    public String heatUpdateAction(HeatDTO dto) {
        heatService.updateHeat(dto);
        return "<script>alert('수정되었습니다.'); window.opener.location.reload(); window.close();</script>";
    }

    // 7. [팝업] 삭제 처리
    @GetMapping("/deleteFromPopup")
    @ResponseBody
    public String deleteFromPopup(@RequestParam("heatNo") Long heatNo) {
        heatService.deleteHeat(heatNo);
        return "<script>alert('삭제되었습니다.'); window.opener.location.reload(); window.close();</script>";
    }

    // (혹시 몰라 유지)
    @GetMapping("/delete")
    public String delete(@RequestParam("heatNo") Long heatNo,
                         @RequestParam("childId") Integer childId,
                         @RequestParam("childName") String childName,
                         RedirectAttributes rttr) {
        heatService.deleteHeat(heatNo);
        rttr.addAttribute("childId", childId);
        rttr.addAttribute("childName", childName);
        return "redirect:/heat/list";
    }
}