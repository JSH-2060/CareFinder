package com.carefinder.dao.heat;

import com.carefinder.dto.heat.HeatDTO;
import com.carefinder.dto.child.ChildDTO; // 임포트 필수
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface HeatDAO {
    // 체온 목록 조회
    List<HeatDTO> selectByChild(Long mno, Integer childId);

    // 체온 추가
    void insertHeat(HeatDTO dto);

    // 체온 삭제
    void deleteHeat(Long heatNo);

    // ★★★ [수정] 이름을 selectChildList 로 통일합니다 ★★★
    List<ChildDTO> selectChildList(Long mno);
}