package com.carefinder.service.vaccine;

import com.carefinder.dao.vaccine.VaccineDAO;
import com.carefinder.dto.vaccine.VaccineDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class VaccineServiceImple implements VaccineService {

    private final VaccineDAO vaccineDAO;

    @Override
    public List<VaccineDTO> getVaccineList(Long mno, Integer childId) {
        return vaccineDAO.selectByChild(mno, childId);
    }

    @Override
    public void addVaccine(VaccineDTO dto) {
        vaccineDAO.insert(dto);
    }

    @Override
    public Integer completeVaccination(Long vaccineNo) {
        // 완료 상태('Y')로 변경
        vaccineDAO.updateStatus(vaccineNo, "Y");
        return null;
    }

    @Override
    public Integer deleteVaccine(Long vaccineNo) {
        vaccineDAO.delete(vaccineNo);
        return null;
    }

    @Override
    public void updateVaccine(VaccineDTO dto) {
        vaccineDAO.update(dto);
    }

    @Override
    public Integer cancelVaccination(Long vaccineNo) {
        // 취소(미접종) 상태('N')로 변경
        vaccineDAO.updateStatus(vaccineNo, "N");
        return null;
    }
}