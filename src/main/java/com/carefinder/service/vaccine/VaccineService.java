package com.carefinder.service.vaccine;

import com.carefinder.dto.vaccine.VaccineDTO;
import java.util.List;

public interface VaccineService {

    // 1. 조회: memberId(String) -> mno(Long), childName(String) -> childId(Integer)
    List<VaccineDTO> getVaccineList(Long mno, Integer childId);

    // 2. 추가
    void addVaccine(VaccineDTO dto);

    // 3. 접종 완료 처리: vacId(int) -> vaccineNo(Long)
    Integer completeVaccination(Long vaccineNo);

    // 4. 삭제: vacId(int) -> vaccineNo(Long)
    Integer deleteVaccine(Long vaccineNo);

    // 5. 수정
    void updateVaccine(VaccineDTO dto);

    // 6. 접종 취소: vacId(int) -> vaccineNo(Long)
    Integer cancelVaccination(Long vaccineNo);
}