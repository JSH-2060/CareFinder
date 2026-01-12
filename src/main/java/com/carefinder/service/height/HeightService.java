package com.carefinder.service.height;

import com.carefinder.dao.height.HeightDAO;
import com.carefinder.dto.height.HeightDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class HeightService {

    private final HeightDAO heightDAO;

    public List<HeightDTO> getList(int childId) {
        return heightDAO.findByChildId(childId);
    }

    public void add(HeightDTO dto) {
        heightDAO.insert(dto);
    }

    public void update(HeightDTO dto) {
        heightDAO.update(dto);
    }

    public void delete(Long heightId) {
        heightDAO.delete(heightId);
    }
}