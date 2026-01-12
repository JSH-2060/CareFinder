package com.carefinder.service.heat;

import com.carefinder.dao.heat.HeatDAO;
import com.carefinder.dto.child.ChildDTO;
import com.carefinder.dto.heat.HeatDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class HeatService {

    private final HeatDAO heatDAO;

    // [1] 자녀 목록 조회 (상단 프로필바용)
    public List<ChildDTO> getChildList(Long mno) {
        return heatDAO.selectChildList(mno);
    }

    // [2] 체온 기록 조회 (특정 자녀 or 본인)
    public List<HeatDTO> getHeatListByChild(Long mno, Integer childId) {
        return heatDAO.selectByChild(mno, childId);
    }

    // [3] 체온 기록 저장
    @Transactional
    public void insertHeat(HeatDTO dto) {
        heatDAO.insertHeat(dto);
    }

    // [4] 체온 기록 삭제
    @Transactional
    public void deleteHeat(Long heatNo) {
        heatDAO.deleteHeat(heatNo);
    }
}