package com.carefinder.dao.vaccine;

import com.carefinder.dto.vaccine.VaccineDTO;
import com.carefinder.dto.child.ChildDTO; // ★ 임포트 필수
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface VaccineDAO {
    List<VaccineDTO> selectByChild(Long mno, Integer childId);
    void insert(VaccineDTO dto);
    void updateStatus(Long vaccineNo, String status);
    void delete(Long vaccineNo);
    void update(VaccineDTO dto);

    // ★★★ [필수 추가] 이게 없으면 백신 페이지가 터집니다.
    List<ChildDTO> selectChildList(Long mno);
}