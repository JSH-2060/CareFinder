package com.carefinder.service.height;

import com.carefinder.dao.height.HeightDAO;
import com.carefinder.dto.height.HeightDTO;
import com.carefinder.dto.child.ChildDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class HeightService {

    private final HeightDAO heightDAO;

    /**
     * 키 목록 조회 (부모 + 자녀 공통)
     */
    public List<HeightDTO> getList(Long mno, Integer childId) {
        if (childId != null && childId == 0) {
            // 본인
            return heightDAO.findByMno(mno);
        } else {
            // 자녀
            return heightDAO.findByChildId(mno, childId);
        }
    }

    /**
     * 키 기록 단건 조회 (수정용)
     */
    public HeightDTO getById(Long heightId) {
        return heightDAO.findById(heightId);
    }

    /**
     * 키 기록 저장
     */
    public void insert(HeightDTO dto) {
        heightDAO.insert(dto);
    }

    /**
     * 키 기록 수정
     */
    public void update(HeightDTO dto) {
        heightDAO.update(dto);
    }

    /**
     * 키 기록 삭제
     */
    public void delete(Long heightId) {
        heightDAO.delete(heightId);
    }

    /**
     * 자녀 목록 (childSelect 재사용용)
     */
    public List<ChildDTO> getChildList(Long mno) {
        return heightDAO.getChildList(mno);
    }
}
