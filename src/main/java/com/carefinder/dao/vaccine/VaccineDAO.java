package com.carefinder.dao.vaccine;

import com.carefinder.dto.vaccine.VaccineDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface VaccineDAO {
    // 조회
    List<VaccineDTO> selectByChild(@Param("mno") Long mno, @Param("childId") Integer childId);

    // 추가
    void insert(VaccineDTO dto);

    // 삭제
    void delete(@Param("vaccineNo") Long vaccineNo);

    // 내용 수정
    void update(VaccineDTO dto);

    // 상태 변경 (완료/취소 처리용)
    void updateStatus(@Param("vaccineNo") Long vaccineNo, @Param("status") String status);
}