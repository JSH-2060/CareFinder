package com.carefinder.dao.heat;

import com.carefinder.dto.heat.HeatDTO;
import com.carefinder.dto.child.ChildDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface HeatDAO {

    // 1. 체온 목록 조회 (mno와 childId를 조건으로 조회)
    List<HeatDTO> selectByChild(@Param("mno") Long mno, @Param("childId") Integer childId);

    // 2. 체온 추가
    void insertHeat(HeatDTO dto);

    // 3. 체온 삭제
    void deleteHeat(Long heatNo);

    // 4. 자녀 목록 조회 (상단 프로필바용)
    List<ChildDTO> selectChildList(Long mno);

    // 5. 체온 기록 수정
    void updateHeat(HeatDTO dto);
}