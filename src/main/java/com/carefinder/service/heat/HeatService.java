package com.carefinder.service.heat;

import com.carefinder.dao.heat.HeatDAO;
import com.carefinder.dto.child.ChildDTO;
import com.carefinder.dto.heat.HeatDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
@RequiredArgsConstructor
public class HeatService {

    private final HeatDAO heatDAO;

    // 자녀 목록 (int -> Long 수정)
    public List<ChildDTO> getChildList(Long mno) {
        return heatDAO.getChildList(mno);
    }

    // 체온 리스트 (String childName -> Integer childId 수정)
    public List<HeatDTO> getHeatListByChild(Long mno, Integer childId) {
        return heatDAO.selectHeatListByChild(mno, childId);
    }

    public void insertHeat(HeatDTO dto) {
        heatDAO.insertHeat(dto);
    }

    public void updateHeat(HeatDTO dto) {
        heatDAO.updateHeat(dto);
    }

    // 삭제 (int -> Long 수정)
    public void deleteHeat(Long heatNo) {
        heatDAO.deleteHeat(heatNo);
    }

    // 단건 조회 (int -> Long 수정)
    public HeatDTO getHeatById(Long heatNo) {
        return heatDAO.getHeatById(heatNo);
    }
}