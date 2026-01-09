package com.carefinder.dao.heat;

import com.carefinder.dto.child.ChildDTO;
import com.carefinder.dto.heat.HeatDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface HeatDAO {

    // 1. 자녀 목록 가져오기 (Child 테이블 조회)
    List<ChildDTO> getChildList(@Param("mno") Long mno);

    // 2. 특정 자녀의 체온 기록 가져오기 (childId 기준)
    List<HeatDTO> selectHeatListByChild(@Param("mno") Long mno, @Param("childId") Integer childId);

    // 3. 체온 기록 저장
    void insertHeat(HeatDTO dto);

    // 4. 수정
    void updateHeat(HeatDTO dto);

    // 5. 삭제 (heatNo 기준)
    void deleteHeat(@Param("heatNo") Long heatNo);

    // 6. 단건 조회 (수정 폼 등에서 사용)
    HeatDTO getHeatById(@Param("heatNo") Long heatNo);
}